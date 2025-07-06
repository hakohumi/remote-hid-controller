#!/bin/bash

set -e

GADGET_DIR=/sys/kernel/config/usb_gadget/game_pad

# ===== 既存のガジェットを削除 =====
if [ -d "$GADGET_DIR" ]; then
  echo "Cleaning up previous gadget..."

  cd "$GADGET_DIR" || exit 1

  # 無効化（UDCを空に）
  if [ -e UDC ]; then
    echo "" | sudo tee UDC
  fi

  # シンボリックリンク削除
  if [ -L configs/c.1/hid.usb0 ]; then
    sudo rm configs/c.1/hid.usb0
  fi

  # functions削除
  if [ -d functions/hid.usb0 ]; then
    sudo rmdir functions/hid.usb0
  fi

  # strings削除
  sudo rm -rf configs/c.1/strings/0x409
  sudo rmdir configs/c.1 2>/dev/null || true
  sudo rm -rf strings/0x409

  # gadgetディレクトリ削除
  cd ..
  sudo rmdir game_pad
fi

# ===== 新しく作成 =====
cd /sys/kernel/config/usb_gadget/
sudo mkdir game_pad
cd game_pad

sudo sh -c 'echo 0x1d6b > idVendor'
sudo sh -c 'echo 0x0104 > idProduct'
sudo sh -c 'echo 0x0100 > bcdDevice'
sudo sh -c 'echo 0x0200 > bcdUSB'

sudo mkdir -p strings/0x409
sudo sh -c 'echo "fedcba9876543210" > strings/0x409/serialnumber'
sudo sh -c 'echo "filu" > strings/0x409/manufacturer'
sudo sh -c 'echo "Remote Game Pad USB Device" > strings/0x409/product'

sudo mkdir -p configs/c.1/strings/0x409
sudo sh -c 'echo "Config 1: HID Combo" > configs/c.1/strings/0x409/configuration'
sudo sh -c 'echo 250 > configs/c.1/MaxPower'

# ===== HID Function 作成 =====
sudo mkdir -p functions/hid.usb0
sudo sh -c 'echo 1 > functions/hid.usb0/protocol'
sudo sh -c 'echo 0 > functions/hid.usb0/subclass'
sudo sh -c 'echo 1 > functions/hid.usb0/report_length'
echo -ne '\x05\x01\x09\x05\xa1\x01\x15\x00\x25\x01\x75\x01\x95\x08\x05\x09\x19\x01\x29\x08\x81\x02\xc0' | sudo tee functions/hid.usb0/report_desc > /dev/null

# ===== 接続 =====
sudo ln -s functions/hid.usb0 configs/c.1/

# ===== デバイス有効化 =====
UDC_NAME=$(ls /sys/class/udc | head -n 1)
echo "$UDC_NAME" | sudo tee UDC
