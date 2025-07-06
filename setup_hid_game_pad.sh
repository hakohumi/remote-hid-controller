#!/bin/bash

# 参考
# https://qiita.com/exthnet/items/98aa9b6d6a606f8f2cf8
# https://qiita.com/exthnet/items/98aa9b6d6a606f8f2cf8
# ChatGPT
# https://qiita.com/sukimaengineer/items/7e49d60ab23962c97428

GADGET_PATH=/sys/kernel/config/usb_gadget/game_pad

UDC=$(ls /sys/class/udc | head -n 1)

# 既存のガジェットがあれば削除
if [ -d "$GADGET_PATH" ]; then
  echo "⚠️ 既存ガジェットを削除します"
  echo "" > "$GADGET_PATH/UDC" || true
  rm -rf "$GADGET_PATH"
fi

# Gadget作成
mkdir -p "$GADGET_PATH"
cd "$GADGET_PATH"

# デバイス情報
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2

# 言語と製品情報
mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "filu" > strings/0x409/manufacturer
echo "Remote Game Pad USB Device" > strings/0x409/product

# 設定定義
mkdir -p configs/c.1/strings/0x409
echo "Config 1: HID Combo" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

# HID Function 作成
mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 1 > functions/hid.usb0/subclass
echo 4 > functions/hid.usb0/report_length

# HID Report Descriptor 書き込み（4バイト構成）
/usr/local/bin/report_descriptor.sh

# Keyboard function
# mkdir -p functions/hid.usb1
# echo 1 > functions/hid.usb1/protocol
# echo 1 > functions/hid.usb1/subclass
# echo 8 > functions/hid.usb1/report_length
# echo -ne '\\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0' > functions/hid.usb1/report_desc

# 接続
ln -s functions/hid.usb0 configs/c.1/
# ln -s functions/hid.usb1 configs/c.1/

# デバイス有効化
echo "$UDC" > UDC