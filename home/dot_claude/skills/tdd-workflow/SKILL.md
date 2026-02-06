---
name: tdd-workflow
description: 新機能の作成、バグ修正、またはPythonコードのリファクタリング時にこのスキルを使用します。ユニット、統合、E2Eテストを含む80%以上のカバレッジでテスト駆動開発を強制します。
allowed-tools: Bash, Read, Write, Edit
model: sonnet
---

# テスト駆動開発ワークフロー

このスキルは、すべてのPythonコード開発がTDD原則に従い、包括的なテストカバレッジを達成することを保証します。

## アクティブ化するタイミング

- 新機能や機能を作成する時
- バグや問題を修正する時
- 既存のコードをリファクタリングする時
- APIエンドポイントを追加する時
- 新しいモジュールを作成する時

## 基本原則

### 1. コードの前にテスト
常に最初にテストを書き、その後テストをパスするコードを実装してください。

### 2. カバレッジ要件
- 最小80%カバレッジ（ユニット + 統合 + E2E）
- すべてのエッジケースをカバー
- エラーシナリオをテスト
- 境界条件を検証

### 3. テストの種類

#### ユニットテスト
- 個別の関数とユーティリティ
- モジュールロジック
- 純粋関数
- ヘルパーとユーティリティ

#### 統合テスト
- APIエンドポイント
- データベース操作
- サービス間の連携
- 外部API呼び出し

#### E2Eテスト（Playwright）
- 重要なユーザーフロー
- 完全なワークフロー
- ブラウザ自動化
- UI操作

## TDDワークフローステップ

### ステップ1：ユーザーストーリーを書く
```
[役割]として、[利益]のために[アクション]したい

例：
ユーザーとして、正確なキーワードがなくても関連するマーケットを見つけられるように、
マーケットを意味的に検索したい。
```

### ステップ2：テストケースを生成
各ユーザーストーリーに対して、包括的なテストケースを作成：

```python
import pytest

class TestSemanticSearch:
    def test_returns_relevant_markets_for_query(self):
        # テスト実装
        pass

    def test_handles_empty_query_gracefully(self):
        # エッジケースのテスト
        pass

    def test_falls_back_to_substring_search_when_redis_unavailable(self):
        # フォールバック動作のテスト
        pass

    def test_sorts_results_by_similarity_score(self):
        # ソートロジックのテスト
        pass
```

### ステップ3：テストを実行（失敗するはず）
```bash
uv run pytest
# テストは失敗するはず - まだ実装していないため
```

### ステップ4：コードを実装
テストをパスするための最小限のコードを書く：

```python
# テストに導かれた実装
async def search_markets(query: str) -> list[Market]:
    # ここに実装
    pass
```

### ステップ5：テストを再実行
```bash
uv run pytest
# テストはパスするはず
```

### ステップ6：リファクタリング
テストをグリーンに保ちながらコード品質を改善：
- 重複を削除
- 命名を改善
- パフォーマンスを最適化
- 可読性を向上

### ステップ7：カバレッジを検証
```bash
uv run pytest --cov=src --cov-report=term-missing
# 80%以上のカバレッジが達成されたことを確認
```

## テストパターン

### ユニットテストパターン（pytest）
```python
import pytest
from mymodule import Button

class TestButton:
    def test_renders_with_correct_text(self):
        button = Button(text="Click me")
        assert button.text == "Click me"

    def test_calls_onclick_when_clicked(self):
        clicked = False

        def on_click():
            nonlocal clicked
            clicked = True

        button = Button(on_click=on_click)
        button.click()

        assert clicked is True

    def test_is_disabled_when_disabled_prop_is_true(self):
        button = Button(disabled=True)
        assert button.disabled is True
```

### API統合テストパターン
```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
class TestMarketsAPI:
    async def test_returns_markets_successfully(self):
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/markets")

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert isinstance(data["data"], list)

    async def test_validates_query_parameters(self):
        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/markets", params={"limit": "invalid"})

        assert response.status_code == 400

    async def test_handles_database_errors_gracefully(self, mocker):
        mocker.patch("app.db.get_markets", side_effect=Exception("DB Error"))

        async with AsyncClient(app=app, base_url="http://test") as client:
            response = await client.get("/api/markets")

        assert response.status_code == 500
```

### E2Eテストパターン（Playwright）
```python
import pytest
from playwright.async_api import Page, expect

@pytest.mark.asyncio
class TestMarketSearch:
    async def test_user_can_search_and_filter_markets(self, page: Page):
        # マーケットページに移動
        await page.goto("/")
        await page.click('a[href="/markets"]')

        # ページが読み込まれたことを確認
        await expect(page.locator("h1")).to_contain_text("Markets")

        # マーケットを検索
        await page.fill('input[placeholder="Search markets"]', "election")

        # デバウンスと結果を待機
        await page.wait_for_timeout(600)

        # 検索結果が表示されたことを確認
        results = page.locator('[data-testid="market-card"]')
        await expect(results).to_have_count(5, timeout=5000)

        # ステータスでフィルタリング
        await page.click('button:has-text("Active")')

        # フィルタリングされた結果を確認
        await expect(results).to_have_count(3)

    async def test_user_can_create_new_market(self, page: Page):
        # 最初にログイン
        await page.goto("/creator-dashboard")

        # マーケット作成フォームに入力
        await page.fill('input[name="name"]', "Test Market")
        await page.fill('textarea[name="description"]', "Test description")
        await page.fill('input[name="endDate"]', "2025-12-31")

        # フォームを送信
        await page.click('button[type="submit"]')

        # 成功メッセージを確認
        await expect(page.locator("text=Market created successfully")).to_be_visible()
```

## テストファイル構成

```
project/
├── src/
│   ├── components/
│   │   └── button.py
│   ├── services/
│   │   └── market_service.py
│   └── api/
│       └── markets.py
├── tests/
│   ├── unit/
│   │   ├── test_button.py
│   │   └── test_market_service.py
│   ├── integration/
│   │   └── test_markets_api.py
│   └── e2e/
│       ├── test_market_search.py
│       └── test_trading.py
└── conftest.py
```

## 外部サービスのモック

### データベースのモック
```python
@pytest.fixture
def mock_db(mocker):
    return mocker.patch("app.db.get_markets", return_value=[
        {"id": 1, "name": "Test Market"}
    ])
```

### Redisのモック
```python
@pytest.fixture
def mock_redis(mocker):
    return mocker.patch(
        "app.services.redis.search_markets_by_vector",
        return_value=[
            {"slug": "test-market", "similarity_score": 0.95}
        ]
    )
```

### 外部APIのモック
```python
@pytest.fixture
def mock_openai(mocker):
    return mocker.patch(
        "app.services.openai.generate_embedding",
        return_value=[0.1] * 1536  # 1536次元の埋め込みをモック
    )
```

## テストカバレッジの検証

### カバレッジレポートの実行
```bash
uv run pytest --cov=src --cov-report=html
```

### カバレッジ設定（pyproject.toml）
```toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=80"

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

## 避けるべき一般的なテストの間違い

### 悪い例：実装の詳細をテスト
```python
# 内部状態をテストしない
assert obj._internal_count == 5
```

### 良い例：ユーザーに見える動作をテスト
```python
# ユーザーに見えるものをテスト
assert obj.count == 5
```

### 悪い例：脆いセレクタ
```python
# 簡単に壊れる
await page.click(".css-class-xyz")
```

### 良い例：セマンティックセレクタ
```python
# 変更に強い
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
```

### 悪い例：テストの分離がない
```python
# テストが互いに依存
def test_creates_user(): ...
def test_updates_same_user(): ...  # 前のテストに依存
```

### 良い例：独立したテスト
```python
# 各テストが独自のデータをセットアップ
def test_creates_user():
    user = create_test_user()
    # テストロジック

def test_updates_user():
    user = create_test_user()
    # 更新ロジック
```

## 継続的テスト

### 開発中のウォッチモード
```bash
uv run pytest-watch
# ファイル変更時にテストが自動実行
```

### プリコミットフック
```bash
# すべてのコミット前に実行
uv run pytest && uv run ruff check
```

### CI/CD統合（GitHub Actions）
```yaml
- name: Run Tests
  run: uv run pytest --cov --cov-fail-under=80
```

## ベストプラクティス

1. **テストを最初に書く** - 常にTDD
2. **テストごとに1つのアサート** - 単一の動作に焦点
3. **説明的なテスト名** - 何がテストされているか説明
4. **Arrange-Act-Assert** - 明確なテスト構造
5. **外部依存関係をモック** - ユニットテストを分離
6. **エッジケースをテスト** - None、空、大きい値
7. **エラーパスをテスト** - ハッピーパスだけでなく
8. **テストを高速に保つ** - ユニットテストは各50ms未満
9. **テスト後にクリーンアップ** - 副作用なし
10. **カバレッジレポートをレビュー** - ギャップを特定

## 成功指標

- 80%以上のコードカバレッジ達成
- すべてのテストがパス（グリーン）
- スキップまたは無効化されたテストなし
- 高速なテスト実行（ユニットテストは30秒未満）
- E2Eテストが重要なユーザーフローをカバー
- テストが本番前にバグをキャッチ

---

**忘れないでください**：テストはオプションではありません。自信を持ってリファクタリングし、迅速に開発し、本番の信頼性を確保するためのセーフティネットです。
