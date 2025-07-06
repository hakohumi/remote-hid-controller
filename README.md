# remote-hid-controller

## 目的

家の外からSwitchのゲームをしたいと思った。

## 手段

操作、映像は？
-> スマホで操作、ゲーム画面の表示

つまり、Switchにコントローラとして接続でき、
無線でコントローラ操作と映像をスマホ側に送受信できるシステムを作成する。

## 構成

- 操作
  - 入力: スマホのブラウザから操作イベントを受け取り、コントローラ操作サーバへ
  - 出力: Raspberry PiをSwitchへ有線で接続し、HIDのゲームパッドとして制御する。
- 映像
  - 入力: SwitchのHDMI出力を、HDMIキャプチャUSBアダプタからwebカメラとして
  - 出力: スマホのブラウザへ

## 詳細

- スマホ
  - webブラウザから
    - コントローラ操作のリクエスト送信
    - 映像の出力

- raspberry pi Zero 2 W
  - 有線でSwitchに接続する。
  - USBコントローラとして動作する。
  - コントローラ操作サーバも立てて、コントローラ操作のリクエストがあったらUSBコントローラとして出力する。

- Raspberry Pi 3
  - HDMIキャプチャUSBアダプタを接続し、Webカメラとして受け取る。
  - 受け取った映像をAPIとして公開する。

### HIDコントローラとしての機能

- ボタン8つ(a,b,x,y,l,r,start,select)
- 十字キー(D-Pad)
- (homeボタン？)(可能なら)

### やったこと

- Raspberry Pi Zero 2 Wのセットアップ
  - Raspberry Pi OS Liteのインストール
  - OTG USB 2.0コントローラの有効化
    - config.txtに dtoverlay=dwc2 を追加する。
  - カーネルモジュールのロード
    - cmdline.txtにmodules-load=dwc2,libcompositeを追加する。
- USB Gadgetの設定
  - /sys/kernel/config/<任意の名前>/に色々作っていく。
    - レポートディスクリプタ
      - ボタン16つ、十字キーの構成のレポートディスクリプタの作成
    - 起動ごとに削除されるため、起動時に毎回作成されるように、生成と適用スクリプトを作成し、サービスとして設定しておく。
- Raspberry Pi Zero 2 W側からHIDに対して操作を行うスクリプトの作成
  - 生成された/dev/hidg0などに対して書き込む

## 参考サイト

USB 公式
<https://www.usb.org/hid>

<https://ifritjp.github.io/documents/singleboard/usb-gadget/>
<https://masawada.hatenablog.jp/entry/2021/02/10/100000>
<https://ifritjp.github.io/documents/singleboard/usb-gadget/>
<https://isecj.jp/blog/raspberry-pi-usb-hid-1/>
