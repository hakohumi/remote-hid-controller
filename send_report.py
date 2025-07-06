#!/usr/bin/env python3

import time
import struct
import math

HID_DEVICE = "/dev/hidg0"

def send_report(buttons, x, y, z, rz):
    """
    buttons: 10bit整数でボタン状態
    x,y,z,rz: 各軸0〜255のアナログ値
    """
    buttons_byte1 = buttons & 0xFF          # 下位8ビット
    buttons_byte2 = (buttons >> 8) & 0x03   # 上位2ビット（ボタン9,10）
    padding1 = 0x00
    padding2 = 0x00

    report = struct.pack(
        "8B",
        buttons_byte1,
        buttons_byte2,
        x,
        y,
        z,
        rz,
        padding1,
        padding2
    )
    with open(HID_DEVICE, "wb") as f:
        f.write(report)
    print(f"✅ Sent: buttons={buttons:010b}, x={x}, y={y}, z={z}, rz={rz}")

if __name__ == "__main__":
    print("🎮 HIDレポート送信開始")

    button_index = 0
    total_buttons = 10
    center = 128
    amplitude = 100
    step = 0
    while True:
        # ボタン1つずつ順番に押す
        buttons = 1 << button_index

        # 各軸をサイン波で動かす（0-255）
        x = int(center + amplitude * math.sin(step / 10))
        y = int(center + amplitude * math.sin(step / 15))
        z = int(center + amplitude * math.sin(step / 20))
        rz = int(center + amplitude * math.sin(step / 25))

        send_report(buttons, x, y, z, rz)

        step += 1
        time.sleep(0.1)

        # 1秒(10ステップ)ごとに次のボタンに切り替え
        if step % 10 == 0:
            button_index = (button_index + 1) % total_buttons
