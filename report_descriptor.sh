#!/bin/bash

# HID レポート記述子を書き込む先のパス
REPORT_DESC_PATH="/sys/kernel/config/usb_gadget/game_pad/functions/hid.usb0/report_desc"

TMP_REPORT="/tmp/game_pad/report_tmp.bin"

# コメント付きで分割した16進バイト列（バイトのみ行とコメント行を分ける）
HEX_DATA=(
  "05 01"       # Usage Page (Generic Desktop)
  "09 05"       # Usage (Game Pad)
  "A1 01"       # Collection (Application)
    "A1 00"        #   Collection (Physical)
      "05 09"       #   Usage Page (Button)
      "19 01"       #   Usage Minimum (Button 1)
      "29 0A"       #   Usage Maximum (Button 10)
      "15 00"       #   Logical Minimum (0)
      "25 01"       #   Logical Maximum (1)
      "95 0A"       #   Report Count (10)
      "75 01"       #   Report Size (1)
      "81 02"       #   Input (Data, Variable, Absolute)

      "95 06"       #   Report Count (6)  ← パディング分
      "75 01"       #   Report Size (1)
      "81 03"       #   Input (Constant, Variable, Absolute) - Padding

      "05 01"       #   Usage Page (Generic Desktop)
      "09 30"       #   Usage (X)
      "09 31"       #   Usage (Y)
      "09 32"       #   Usage (Z)
      "09 35"       #   Usage (Rz)
      "15 00"       #   Logical Minimum (0)
      "26 FF 00"    #   Logical Maximum (255)
      "75 08"       #   Report Size (8)
      "95 04"       #   Report Count (4)
      "81 02"       #   Input (Data, Variable, Absolute)
    "C0"           #   End Collection (Physical)
  "C0"           # End Collection (Application)
  )

# 出力ファイルを空に初期化
> "$REPORT_DESC_PATH"

# 一時バイナリファイル作成
mkdir -p "$(dirname "$TMP_REPORT")"
> "$TMP_REPORT"

# 配列の各行を処理
for line in "${HEX_DATA[@]}"; do
  # 行を空白で分割し、1バイトずつバイナリ出力
  for byte in $line; do
    # printf "\\x$byte" >> "$REPORT_DESC_PATH"
    printf "\\x$byte" >> "$TMP_REPORT"
  done
done

# 中身確認
echo "🔍 レポート内容:"
hexdump -C "$TMP_REPORT"


# 書き込み
cat "$TMP_REPORT" > "$REPORT_DESC_PATH"
rm "$TMP_REPORT"

echo "✅ HID report descriptor written to $REPORT_DESC_PATH"
