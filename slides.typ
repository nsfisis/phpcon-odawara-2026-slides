#import "@preview/touying:0.6.3": *
#import "@preview/codly:1.3.0": *
#import "@preview/cjk-unbreak:0.2.0": remove-cjk-break-space, transform-childs
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "setoka.typ": *

#show: codly-init.with()

#show: remove-cjk-break-space

#show: setoka-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [
      Deep Dive into Xdebug
    ],
    subtitle: [PHP カンファレンス小田原 2026],
    author: [nsfisis (いまむら)],
    date: datetime(year: 2026, month: 4, day: 11),
  ),
  config-common(preamble: {
    codly(
      fill: rgb("#eee"),
      lang-format: none,
      number-format: none,
      zebra-fill: none,
    )
  })
)

#set text(font: "BIZ UDPGothic", lang: "ja")
#show raw: set text(font: "UDEV Gothic 35")

#let box-color-highlight = rgb("#ffa500").lighten(60%)
#let box-color-highlight2 = rgb("#ffa500")
#let box-color-normal = rgb("#eee")

#title-slide()

#about-slide()

#[
  #set align(center + horizon)
  #set text(size: 40pt)
  Xdebug のステップ実行は\
  どう実現されているのか
]

---

#[
  #set text(size: 30pt)

  Xdebug

  - PHP の拡張 (extension)
  - ステップ実行
  - トレース
  - プロファイリング
  - コードカバレッジ計測
]

---

#[
  #set align(center + horizon)

  今回はステップ実行の話
]

---

#[
  #set align(center + horizon)

  ステップ実行

  #figure(
    image("./ss1.png", width: 60%)
  )
]

---

#[
  #set align(center + horizon)

  ステップ実行

  #figure(
    image("./ss2.png", width: 60%)
  )
]

---

#[
  #set align(center + horizon)
  #set text(size: 32pt)

  ステップ実行は \
  どのように実装されているのか？
]

---

#[
  #set align(center + horizon)
  #set text(size: 28pt)

  #diagram(
    spacing: 8em,
    node-stroke: 0.5pt,
    node((0, 0), [IDE], shape: rect, fill: box-color-normal, inset: 1em, corner-radius: 4pt),
    node((1, 0), [PHP + Xdebug], shape: rect, fill: box-color-normal, inset: 1em, corner-radius: 4pt),
    edge((0, 0), (1, 0), "->", shift: 8pt),
    edge((1, 0), (0, 0), "->", shift: 8pt),
  )
]

---

#[
  #set align(center + horizon)
  #set text(size: 28pt)

  #diagram(
    spacing: 8em,
    node-stroke: 0.5pt,
    node((0, 0), [IDE], shape: rect, fill: box-color-highlight, inset: 1em, corner-radius: 4pt),
    node((1, 0), [PHP + Xdebug], shape: rect, fill: box-color-normal, inset: 1em, corner-radius: 4pt),
    edge((0, 0), (1, 0), "->", shift: 8pt),
    edge((1, 0), (0, 0), "->", shift: 8pt),
  )
]

---

#[
  #set align(center + horizon)
  #set text(size: 28pt)

  #diagram(
    spacing: 8em,
    node-stroke: 0.5pt,
    node((0, 0), [IDE], shape: rect, fill: box-color-normal, inset: 1em, corner-radius: 4pt),
    node((1, 0), [PHP + Xdebug], shape: rect, fill: box-color-highlight, inset: 1em, corner-radius: 4pt),
    edge((0, 0), (1, 0), "->", shift: 8pt),
    edge((1, 0), (0, 0), "->", shift: 8pt),
  )
]

---

#[
  #set align(center + horizon)

  #figure(
    image("./d78b28e5-0358-4e7e-a32b-fc20106f7547.png", width: 80%)
  )
]

---

#[
  #set align(center + horizon)
  #set text(size: 28pt)

  #diagram(
    spacing: (0em, 1.5em),
    node-stroke: 0.5pt,
    node((0, 0), [ソースコード], shape: rect, fill: box-color-normal, inset: 0.5em, corner-radius: 4pt),
    node((0, 1), [AST], shape: rect, fill: box-color-normal, inset: 0.5em, corner-radius: 4pt),
    node((0, 2), [opcode], shape: rect, fill: box-color-normal, inset: 0.5em, corner-radius: 4pt),
    node((0, 3), [実行結果], shape: rect, fill: box-color-normal, inset: 0.5em, corner-radius: 4pt),
    edge((0, 0), (0, 1), "->"),
    edge((0, 1), (0, 2), "->"),
    edge((0, 2), (0, 3), "->"),
  )
]

---

#[
  #set page(margin: (x: 96pt, y: 48pt))
  #set align(center + horizon)

  #set text(size: 24pt)

  #codly-range(2)
  ```php
  <?php
  echo "Hello, ";
  echo "Odawara!\n";
  ```
    ↓
  ```
  ECHO string("Hello, ")
  ECHO string("Odawara!\n")
  ```
]

#[
  #set page(margin: (x: 96pt, y: 48pt))
  #set align(center + horizon)

  #set text(size: 24pt)

  #codly-range(2)
  ```php
  <?php
  echo "Hello, ";
  echo "Odawara!\n";
  ```
    ↓
  #codly(highlights: (
    (line: 1, fill: box-color-highlight2),
    (line: 3, fill: box-color-highlight2),
  ))
  ```
  EXT_STMT
  ECHO string("Hello, ")
  EXT_STMT
  ECHO string("Odawara!\n")
  ```
]

#[
  #set text(size: 20pt)

  ```c
  // php-src: Zend/zend_vm_def.h
  ZEND_VM_COLD_HANDLER(ZEND_EXT_STMT) {
      // 予め登録されているハンドラをすべて呼び出す
      zend_llist_apply_with_argument(
          &zend_extensions,
          zend_extension_statement_handler,
          execute_data
      );
  }
  ```
]

---

#[
  #set text(size: 20pt)

  ```c
  // xdebug: xdebug.c
  void xdebug_statement_call(zend_execute_data *frame) {
      if (ステップ実行が有効になっている？) {
          xdebug_debugger_statement_call(...);
      }
  }
  ```
]

---

#[
  #set text(size: 20pt)

  ```c
  // xdebug: src/debugger/debugger.c
  void xdebug_debugger_statement_call(...) {
      if (step out している？) { ... }
      if (step over している？) { ... }
      if (step into している？) { ... }
      if (この行にブレークポイントが設定されている？) { ... }
  }
  ```
]

---

#[
  #set text(size: 20pt)

  ```c
  // xdebug: src/debugger/handler_dbgp.c
  int xdebug_dbgp_breakpoint(...) {
      // レスポンスを生成して IDE へ送信
      send_message(context, response);
      // IDE からの命令を待ち受けるループへ入る
      xdebug_dbgp_cmdloop(...);
  }
  ```
]

---

#[
  #set text(size: 20pt)
  #set page(margin: (x: 96pt, y: 48pt))

  ```c
  // xdebug: src/debugger/handler_dbgp.c
  static int xdebug_dbgp_cmdloop(...) {
      do {
          // IDE からの命令を待ち受け
          option = xdebug_fd_read_line_delim(...);
          // IDE からの命令を実行
          // ret: 1=プログラムの実行再開 / 0=その他の命令
          ret = xdebug_dbgp_parse_option(...);
          if (ret != 1) {
              send_message(context, response);
          }
      } while (ret != 1);
  }
  ```
]

#[
  #set align(center + horizon)

  #set text(size: 30pt)

  ここまでのまとめ

  #set text(size: 24pt)

  #align(left)[
    - コンパイル時、各ステートメントの前に `EXT_STMT` が\
      挿入される
    - `EXT_STMT` 実行時に Xdebug のハンドラが呼ばれる
    - IDE へレスポンスを送信し、命令待ちループへ
    - IDE から実行再開命令が来ると、ループを抜けて\
      実行を再開
  ]
]

---

#[
  #set align(center + horizon)

  Xdebug はあくまで\
  PHP の一拡張として\
  実現されている

  #pause→ 自分でも作れるはず
]

---

#[
  #set align(center + horizon)

  ミニ Xdebug を作ろう！
]

---

#[
  #set align(center + horizon)
  #set text(size: 20pt)

  https://github.com/nsfisis/mini-xdebug

  #figure(
    image("./mini-xdebug.png", width: 60%)
  )
]

---

#[
  #set align(center + horizon)

  ご清聴\
  ありがとうございました
]

---

#[
  #set text(size: 20pt)

  参考文献:

  - https://github.com/php/php-src
  - https://github.com/xdebug/xdebug
  - https://xdebug.org/docs/step_debug
  - https://xdebug.org/docs/dbgp
  - https://speakerdeck.com/shin1x1/exploring-how-debugging-works-with-xdebug-and-an-ide
]
