---
id: SPEC-rsvp-html-infographic
status: active
created_at: 2026-09-30
updated_at: 2026-10-01
related_guides:
  - GUIDE-rsvp-clipboard
affected_workstreams: []
---

# RSVPのクリップボード本文をHTML図解にする

## Purpose

クリップボード本文の構造と要点を、見やすい図解で素早く把握できるようにする。

## Problem

RSVPで文章を読むだけでは、内容間の関係や全体構造を一覧しにくい。

## Goals

- Readerで `f` を押したとき、起動時に取り込んだクリップボード本文をもとに図解を生成する。
- 生成した自己完結型HTMLをWeb表示し、本文の構造と主要な関係を見渡せるようにする。
- 生成結果は一時ファイルとして扱い、Escapeで表示を終了したときに削除する。
- 既存のClaude Code互換CLI設定とサブスクリプション認証を使い、従量課金APIを使わない。
- 生成プロンプトは利用者がファイルを開いて編集できる。
- `h` / `l` で10秒戻る・進む。`k` / `j` でWPMを25ずつ上げる・下げる。

## Non-Goals

- Claude.aiのArtifactsギャラリーへの登録、公開、同期。
- 従量課金APIへの直接接続。
- 生成HTMLを永続的な資料として保存・管理する機能。
- 今回の図解生成を使ったクイズや理解度判定。

## Domain Language

| Term | Meaning | Boundary or contrast |
| --- | --- | --- |
| 図解HTML | クリップボード本文から生成される1ページのHTML図解 | RSVP本文やClaude.aiのArtifacts一覧とは別の一時成果物 |
| 図解セッション | `f` の押下から図解表示を閉じるまで | 図解HTMLはこのセッションのためだけに保持する |

## Actors and Scenarios

- 利用者がReaderで `f` を押すと、本文から図解HTMLを生成してWeb表示する。
- 図解を既定ブラウザで開いた後もRSVPは起動したままにし、ブラウザを閉じてもReaderの状態を保持する。
- 利用者がRSVPに戻ってEscapeを押すかReaderウィンドウを閉じると、図解セッションのHTMLを削除する。
- 生成が失敗したときは、原文を残したまま安全なエラーを表示し、HTMLファイルを残さない。
- アプリが異常終了して一時ファイルが残った場合、次の起動時にアプリ所有の古い図解一時データを回収する。

## Requirements

### Functional

- Readerの `f` ショートカットから、起動時のクリップボード本文を使って図解生成を開始できる。
- 図解生成にはRaycastで指定されたClaude Code互換CLIを使い、初期値は既存の `claude2` とする。
- 図解プロンプトはApplication Supportに作成し、利用者による編集を後続起動でも保持する。
- 図解HTMLは一時保存場所にセッション単位で保存し、通常の文書・リポジトリ・拡張バンドルへ保存しない。
- CLI出力と検証後のHTMLは1.5 MBを上限とし、超過時は開かず一時ファイルを残さない。
- 図解HTMLをmacOSの既定ブラウザで開き、ブラウザを閉じてもRSVP Readerのプロセスとウィンドウを維持する。
- `f` を押した時点でRSVP再生を一時停止し、図解の表示中も再生位置を保持する。
- RSVPが入力を受け取っている間、`h` / `l` は左右矢印と同じ10秒スキップ、`k` / `j` は上下矢印と同じWPM調整として動作する。
- 利用者がRSVPに戻ってEscapeを押すかReaderウィンドウを閉じたとき、当該セッションのHTMLと一時ディレクトリを削除する。
- 異常終了後に残ったセッションは次回起動時に回収する。稼働中の別RSVPセッションの一時データは削除しない。常駐の期限管理処理は設けない。
- 生成失敗時に生のCLI出力、プロンプト、クリップボード本文をエラー画面に表示しない。

### Quality

- クリップボード本文をプロンプト内の資料として扱い、本文中の命令に従って実行や外部操作をしない。
- 図解HTMLは自己完結型とし、Content Security Policyでスクリプト実行と外部ネットワーク参照を禁止する。アンカーリンクなどのナビゲーションも許可しない。
- 一時HTMLは他ユーザーから読めない権限で作成し、清掃対象はRSVP専用の一時領域に限定する。
- 図解生成経路から従量課金APIキー、代替プロバイダー環境変数、任意のCLIツールを使わない。

## Design Direction

- 既存のCLI起動・サブスクリプション環境ブリッジを再利用する。
- 出力を標準出力から受け取り、HTMLとして検証した後、セッション固有の一時領域に書き込む。
- URL除去後の本文を入力し、既定ブラウザでローカルのHTMLファイルを開く。
- RSVPが起動している間だけ図解HTMLを保持する。正常終了時に即時削除し、次回起動時に異常終了後のRSVP専用セッションを回収する。
- 図解プロンプトは `~/Library/Application Support/RSVP Clipboard/diagram.md` に初期作成し、既存編集を保持する。

## Deferred Decisions

- 次段階の構造マップ `m` とのショートカット統合は、同じ図解生成を別表示で要求した時点で決める。
- 図解の具体的な色、レイアウト、図表形式は、編集可能なプロンプトの初期案で定める。

## Related Decision

- [ADR-20261001-rsvp-disposable-html-diagram-hjkl](../adrs/ADR-20261001-rsvp-disposable-html-diagram-hjkl.md) — disposable HTML lifecycle, browser handoff, and HJKL aliases.
