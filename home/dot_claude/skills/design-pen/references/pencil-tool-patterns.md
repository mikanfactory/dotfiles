# Pencil batch_design 操作パターン集

実装ステップで参照する `batch_design` の具体的な操作パターン。

## 目次

- [基本構文](#基本構文)
- [フレーム構造の構築](#フレーム構造の構築)
- [コンポーネントインスタンスの操作](#コンポーネントインスタンスの操作)
- [テキスト挿入・更新](#テキスト挿入更新)
- [画像適用](#画像適用)
- [コピーとバリエーション](#コピーとバリエーション)
- [注意事項](#注意事項)

## 基本構文

操作は JavaScript 風の構文で記述する。各行が1操作。

| 操作 | 構文 | 用途 |
|------|------|------|
| Insert | `foo=I(parent, {...})` | 新規ノード挿入 |
| Copy | `bar=C(nodeId, parent, {...})` | ノード複製 |
| Update | `U(path, {...})` | プロパティ更新 |
| Replace | `baz=R(path, {...})` | ノード置換 |
| Move | `M(nodeId, parent, index)` | ノード移動 |
| Delete | `D(nodeId)` | ノード削除 |
| Image | `G(nodeId, type, prompt)` | 画像生成・適用 |

## フレーム構造の構築

### 画面フレームの作成

```javascript
screen=I(document, {type: "frame", name: "Home Screen", width: 1440, height: 900, fill: "#FFFFFF"})
```

### レイアウト構造（サイドバー + メイン）

```javascript
sidebar=I("parentId", {type: "frame", layout: "vertical", width: 240, height: "fill_container", gap: 8, padding: 16})
main=I("parentId", {type: "frame", layout: "vertical", gap: 24, padding: 32, width: "fill_container"})
```

### グリッドレイアウト

```javascript
grid=I("parentId", {type: "frame", layout: "horizontal", gap: 16, wrap: true})
card1=I(grid, {type: "frame", layout: "vertical", width: 300, height: 200, padding: 16})
card2=I(grid, {type: "frame", layout: "vertical", width: 300, height: 200, padding: 16})
```

## コンポーネントインスタンスの操作

### インスタンス挿入

```javascript
btn=I("parentId", {type: "ref", ref: "ButtonCompId", width: 120})
```

### インスタンス内のプロパティ更新

スラッシュ区切りでインスタンス内部のノードにアクセスする。

```javascript
card=I("parentId", {type: "ref", ref: "CardCompId"})
U(card+"/titleText", {content: "Card Title"})
U(card+"/descText", {content: "Description here"})
```

### インスタンス内のノード置換

```javascript
newNode=R("instanceId/slotId", {type: "text", content: "Replaced Content"})
```

### children オーバーライド付きインスタンス

```javascript
list=I("parentId", {type: "ref", ref: "ListCompId", children: [{type: "text", content: "Item 1"}, {type: "text", content: "Item 2"}]})
```

## テキスト挿入・更新

### テキスト挿入

```javascript
title=I("parentId", {type: "text", content: "Page Title", fontSize: 32, fontWeight: "bold"})
body=I("parentId", {type: "text", content: "Body text here", fontSize: 16, color: "#333333"})
```

### テキスト更新

```javascript
U("textNodeId", {content: "Updated text"})
```

### 引用符を含むテキスト

HTML エンティティを使用する。

```javascript
quote=I("parentId", {type: "text", content: "&quot;Quoted text&quot;"})
```

## 画像適用

画像は frame/rectangle ノードの fill として適用する。**image ノード型は存在しない。**

### AI 生成画像

```javascript
heroImg=I("parentId", {type: "frame", name: "Hero Image", width: 400, height: 300})
G(heroImg, "ai", "modern office workspace, bright natural lighting")
```

### ストック画像（Unsplash）

```javascript
photo=I("parentId", {type: "frame", name: "Profile Photo", width: 80, height: 80, cornerRadius: [40,40,40,40]})
G(photo, "stock", "professional headshot portrait")
```

## コピーとバリエーション

### ノードのコピー

```javascript
copy=C("originalId", "parentId", {name: "Copy of Original"})
```

### コピー + 位置指定

```javascript
variant=C("screenId", document, {name: "Screen V2", positionDirection: "right", positionPadding: 100})
```

### コピー + 子孫のカスタマイズ

Copy 内で `descendants` を使う。**Copy 後に別の Update で子孫を変更してはならない**（ID が変わるため失敗する）。

```javascript
card=C("cardCompId", "parentId", {descendants: {"titleText": {content: "New Title"}, "descText": {content: "New Desc"}}})
```

## 注意事項

- **id は自動生成**: Insert/Replace で `id` プロパティを指定しない
- **1操作1行**: 各行は必ず1つの操作呼び出し
- **バインディングは同一 batch_design 内のみ有効**: 複数回の呼び出しにまたがってバインディングを使えない
- **バインディング名は毎回新規**: 同じ名前を再利用しない
- **Copy の子孫更新は descendants で**: Copy 後に Update で子孫を変更すると ID 不一致で失敗する
- **25操作/回の制限**: 大規模変更は複数回に分割する
- **placeholder フレーム**: `placeholder: true` のフレームは子要素のコンテナとして使用する
