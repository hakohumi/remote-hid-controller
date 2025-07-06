# !/bin/bash

# 参考
# https://qiita.com/exthnet/items/98aa9b6d6a606f8f2cf8
# https://qiita.com/exthnet/items/98aa9b6d6a606f8f2cf8
# ChatGPT
# https://qiita.com/sukimaengineer/items/7e49d60ab23962c97428

GADGET_DIR=/sys/kernel/config/usb_gadget/game_pad

if [ -d "$GADGET_DIR" ]; then
  echo "Cleaning up previous gadget..."
  cd "$GADGET_DIR"
  echo "" > UDC 2>/dev/null
  rm -f configs/c.1/hid.usb0
  rmdir functions/hid.usb0 2>/dev/null
  cd ..
  rm -rf game_pad
fi

cd /sys/kernel/config/usb_gadget/

mkdir -p game_pad
cd game_pad
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2

mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "filu" > strings/0x409/manufacturer
echo "Remote Game Pad USB Device" > strings/0x409/product

mkdir -p configs/c.1/strings/0x409
echo "Config 1: HID Combo" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower


# Add functions here
mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 0 > functions/hid.usb0/subclass
echo 1 > functions/hid.usb0/report_length
echo -ne '\\x05\\x01\\x09\\x05\\xa1\\x01\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x05\\x09\\x19\\x01\\x29\\x08\\x81\\x02\\x75\\x08\\x95\\x01\\x81\\x03\\xc0' > functions/hid.usb0/report_desc

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
echo "" > UDC  # 無効化
ls /sys/class/udc > UDC  # 再有効化