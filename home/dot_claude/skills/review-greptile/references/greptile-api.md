# Greptileレビューの取得・待機・返信リファレンス

`review-greptile` / `refine-loop` / `revise-loop` が共有する、GitHub API経由のGreptile連携手順。
`{owner}` `{repo}` `{pr}` は実値に置換して使う。

## 1. Greptileの投稿先

| ソース | エンドポイント | 内容 |
|---|---|---|
| サマリ | `repos/{owner}/{repo}/issues/{pr}/comments` | `<h3>Greptile Summary</h3>`（旧 `Greptile Overview`）で始まる総括と `Confidence Score: N/5`。**指摘0件でも必ず投稿される**。再レビュー時は新規作成せず**同じ`id`を編集**し`updated_at`のみ更新する |
| インライン | `repos/{owner}/{repo}/pulls/{pr}/comments` | ファイル・行に紐づく指摘。指摘が無ければ0件 |
| レビュー | `repos/{owner}/{repo}/pulls/{pr}/reviews` | 多くは `state=COMMENTED` で `body` が空。**body空は完了判定に使わない** |

- bot判定は必ず `.user.login | test("greptile"; "i")`（実際のログインは `greptile-apps[bot]`。case-insensitiveにする）
- `pulls/{pr}/reviews/{review_id}/comments` は `pulls/{pr}/comments` に包含されるため使わない
- **サマリを見ないとレビュー済みを検知できない**。指摘0件のPRではインライン0件・レビューbody空になり、サマリだけが唯一の完了シグナルになる

## 2. スナップショット取得（差分検出の基礎）

3ソースを `種別<TAB>id<TAB>更新時刻` の行に正規化する。`--paginate` は行出力とは正しく組み合わせられる。

```bash
OWNER_REPO="{owner}/{repo}"; PR={pr}
STATE_DIR="${TMPDIR:-/tmp}/greptile-$(echo "$OWNER_REPO" | tr '/' '-')-$PR"
mkdir -p "$STATE_DIR"

snapshot() {
  {
    gh api "repos/$OWNER_REPO/issues/$PR/comments" --paginate \
      --jq '.[] | select(.user.login | test("greptile";"i")) | "issue\t\(.id)\t\(.updated_at)"'
    gh api "repos/$OWNER_REPO/pulls/$PR/comments" --paginate \
      --jq '.[] | select(.user.login | test("greptile";"i")) | "inline\t\(.id)\t\(.updated_at)"'
    gh api "repos/$OWNER_REPO/pulls/$PR/reviews" --paginate \
      --jq '.[] | select((.user.login | test("greptile";"i")) and (((.body // "") | length) > 0)) | "review\t\(.id)\t\(.submitted_at)"'
  } 2>/dev/null | sort
}
```

## 3. ベースライン記録

```bash
snapshot > "$STATE_DIR/baseline.txt"
wc -l < "$STATE_DIR/baseline.txt"
```

- 新規PR（初回レビュー待ち）は `: > "$STATE_DIR/baseline.txt"` で空にする
- 状態ファイルは **owner/repo と PR番号でスコープする**（固定名は別PR間で衝突する）

## 4. 完了待ちポーリング

**`Bash`ツールを `run_in_background: true` で実行する。** 条件成立またはタイムアウトで`exit`するため、完了時にハーネスが自動で通知する。foregroundの`sleep`はブロックされるのでバックグラウンド実行が必須。

```bash
for i in $(seq 1 30); do
  snapshot > "$STATE_DIR/current.txt"
  DIFF=$(comm -13 "$STATE_DIR/baseline.txt" "$STATE_DIR/current.txt")
  if [ -n "$DIFF" ]; then
    echo "GREPTILE_READY"
    echo "$DIFF"
    exit 0
  fi
  echo "poll $i: no change"
  sleep 30
done
echo "GREPTILE_TIMEOUT"
```

- 30秒 × 30回 = 最大15分
- `comm -13` の出力行が **新規id、または `updated_at` が変化した既知id**（＝再レビューによるサマリ本文更新）を表す

## 5. 本文の取得

`GREPTILE_READY` 後に本文を取得する。

```bash
# サマリ
gh api "repos/$OWNER_REPO/issues/$PR/comments" --paginate \
  --jq '[.[] | select(.user.login | test("greptile";"i")) | {id, updated_at, body}]'
# インライン
gh api "repos/$OWNER_REPO/pulls/$PR/comments" --paginate \
  --jq '[.[] | select(.user.login | test("greptile";"i")) | {id, in_reply_to_id, updated_at, path, line: (.line // .original_line), side, body, diff_hunk}]'
# レビュー（body非空のみ）
gh api "repos/$OWNER_REPO/pulls/$PR/reviews" --paginate \
  --jq '[.[] | select((.user.login | test("greptile";"i")) and (((.body // "") | length) > 0)) | {id, state, body}]'
```

### 5.1 スレッド返信の見分け方

`in_reply_to_id` が `null` でないGreptileコメントは、既存スレッドへのGreptile自身の返答（こちらの返信に対する再応答など）。新規の独立した指摘ではないため、**同じスレッドの流れとして読み**、返信する場合も同じスレッドへ返す。

## 6. サマリ本文の扱い

- 本文はHTML混在（`<h3>` など）で、`Confidence Score: N/5` と箇条書きの所見を含む
- **インラインコメントが0件でもサマリ本文に指摘が書かれることがあるため、サマリも必ず分析対象に含める**
- サマリはファイル・行に紐づかないため「総括コメント」として扱う

## 7. Greptileへの返信

分析・修正が完了したら、**Greptileが投稿したコメントに限り**、対応可否と理由を返信する。

### 7.1 返信対象の判定

- **返信してよいのは `.user.login | test("greptile";"i")` にマッチするコメントのみ**
- **人間のコメント・自分のコメント・他のbotのコメントには絶対に返信しない**
- 既に自分が返信済みのスレッドには再返信しない。自分のログインと `in_reply_to_id` で判定する:

```bash
ME=$(gh api user --jq '.login')
gh api "repos/$OWNER_REPO/pulls/$PR/comments" --paginate \
  --jq '.[] | select(.in_reply_to_id != null) | "\(.user.login)\t\(.in_reply_to_id)"' \
  | awk -F'\t' -v me="$ME" '$1 == me { print $2 }' | sort -u
```

出力に含まれる`id`のスレッドはスキップする。`gh api --jq` は `--arg` を受け付けないため、ログイン比較は`awk`側で行う。

### 7.2 インラインコメントへの返信（スレッド返信）

```bash
gh api --method POST "repos/$OWNER_REPO/pulls/$PR/comments/{comment_id}/replies" \
  -f body="$(cat <<'EOF'
**対応しました** — <何をどう直したかを1〜2文で>
EOF
)"
```

対応しない場合:

```bash
gh api --method POST "repos/$OWNER_REPO/pulls/$PR/comments/{comment_id}/replies" \
  -f body="$(cat <<'EOF'
**対応見送り** — <スキップの根拠を1〜2文で>
EOF
)"
```

### 7.3 サマリ・総括レビューへの返信（PRコメント1件に集約）

サマリ（issueコメント）とレビュー本文はスレッド返信できないため、**PR全体へのコメント1件にまとめて投稿する**。インラインの対応結果もこの表に含めて全体像が分かるようにする。

```bash
gh pr comment {pr} --body "$(cat <<'EOF'
## Greptileレビューへの対応結果

| # | 対象 | 判定 | 理由 |
|---|------|------|------|
| 1 | `src/api/users.py:42` | 対応 | Noneチェックを追加 |
| 2 | `src/utils/helper.py:15` | 見送り | 命名はドメイン用語に基づいており適切 |
| 3 | 総括コメント | 対応 | 指摘のあったエラーハンドリングを追加 |
EOF
)"
```

### 7.4 返信文のルール

- 日本語で書く
- 「対応しました」/「対応見送り」のどちらかを**必ず先頭に太字で書く**
- 理由は1〜2文。対応した場合は**何をどう直したか**、見送った場合は**なぜ不要と判断したか**を書く
- 謝辞・定型の挨拶・Claudeの署名は入れない
- 修正が**コミット・push済みの状態で**返信する（返信内容と実際のコードを一致させるため）

## 8. 落とし穴

- `--paginate` と `--jq '[...] | length'` は**併用不可**（ページごとに件数が出力され、複数行になる）。件数は行出力 + `wc -l` で数える
- `[ A ] || [ B ] && { ...; }` は使わず `if` 文にする
- bot判定は必ず `"i"` フラグ付き（`test("greptile")` は case-sensitive）
- Greptileは **Draft PR にもコメントする**（Draftであること自体は問題ではない）
- 自分が投稿した返信は `pulls/{pr}/comments` にも現れるが、login フィルタで除外されるためスナップショットは汚染されない
