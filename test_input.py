from pywinusb import hid
import time

def on_data_received(data):
    print(f"[LOG] Received report: {data}")

devices = hid.HidDeviceFilter(vendor_id=0x1d6b, product_id=0x0104).get_devices()

if not devices:
    print("デバイスが見つかりませんでした")
    exit()

device = devices[0]
device.open()
device.set_raw_data_handler(on_data_received)

print("Listening for reports... (Ctrl+C to stop)")
try:
    while True:
        time.sleep(0.1)
except KeyboardInterrupt:
    device.close()
