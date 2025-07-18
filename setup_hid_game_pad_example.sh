#!/bin/bash

# 参考
# https://www.mzyy94.com/blog/2020/03/20/nintendo-switch-pro-controller-usb-gadget/
# https://qiita.com/exthnet/items/98aa9b6d6a606f8f2cf8
# ChatGPT
# https://qiita.com/sukimaengineer/items/7e49d60ab23962c97428

GADGET_PATH=/sys/kernel/config/usb_gadget/game_pad

UDC=$(ls /sys/class/udc | head -n 1)

# 既存のガジェットがあれば削除
if [ -d "$GADGET_PATH" ]; then
  echo "⚠️ 既存ガジェットを削除します"
  echo "" | sudo tee "$GADGET_PATH/UDC" > /dev/null || true
  rm $GADGET_PATH/configs/c.1/hid.usb0
  rmdir $GADGET_PATH/configs/c.1/strings/0x409/
  rmdir $GADGET_PATH/configs/c.1
  rmdir $GADGET_PATH/functions/hid.usb0
  rmdir $GADGET_PATH/strings/0x409
  rmdir $GADGET_PATH
fi

# Gadget作成
mkdir -p "$GADGET_PATH"
cd "$GADGET_PATH"

# デバイス情報
echo 0x057e > idVendor
echo 0x2009 > idProduct
echo 0x0200 > bcdDevice
echo 0x0200 > bcdUSB
echo 0x00 > bDeviceClass
echo 0x00 > bDeviceSubClass
echo 0x00 > bDeviceProtocol

# 言語と製品情報
mkdir -p strings/0x409
echo "000000000001" > strings/0x409/serialnumber
echo "Nintendo Co., Ltd." > strings/0x409/manufacturer
echo "Pro Controller" > strings/0x409/product

# 設定定義
mkdir -p configs/c.1/strings/0x409
echo "Nintendo Switch Pro Controller" > configs/c.1/strings/0x409/configuration
echo 500 > configs/c.1/MaxPower
echo 0xa0 > configs/c.1/bmAttributes

# HID Function 作成
mkdir -p functions/hid.usb0

echo 0 > functions/hid.usb0/protocol
echo 0 > functions/hid.usb0/subclass
echo 64 > functions/hid.usb0/report_length
echo 050115000904A1018530050105091901290A150025017501950A5500650081020509190B290E150025017501950481027501950281030B01000100A1000B300001000B310001000B320001000B35000100150027FFFF0000751095048102C00B39000100150025073500463B0165147504950181020509190F2912150025017501950481027508953481030600FF852109017508953F8103858109027508953F8103850109037508953F9183851009047508953F9183858009057508953F9183858209067508953F9183C0 | xxd -r -ps > functions/hid.usb0/report_desc

# 接続
ln -s functions/hid.usb0 configs/c.1/

# デバイス有効化
echo "$UDC" > "$GADGET_PATH/UDC"