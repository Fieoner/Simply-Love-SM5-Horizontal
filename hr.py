#!/usr/bin/env python3

import pygatt
from time import sleep

MAC_ADDRESS = 'D5:22:BC:4D:04:D7'
ADDRESS_TYPE = pygatt.BLEAddressType.random # polar h10 works like this. don't ask me lol
HR_FILE = 'hr.out'

adapter = pygatt.GATTToolBackend()

def callback(handle, measure):
    if handle == 16:
        hr = measure[1]
        print(hr)
        with open(HR_FILE, 'w') as f:
            f.write(str(hr))

try:
    print("starting adapter")
    adapter.start()
    print("connecting to h10")
    device = adapter.connect(MAC_ADDRESS, address_type=ADDRESS_TYPE)
    device.bond()
    print("discovering")
    device.discover_characteristics()
        # https://gist.github.com/sam016/4abe921b5a9ee27f67b3686910293026#file-allgattcharacteristics-java-L63
    device.subscribe('00002a37-0000-1000-8000-00805f9b34fb', callback)
    print("connected")
    while True:
        sleep(1)

except Exception as e:
    print(e)
    print('asdf')
except KeyboardInterrupt:
    print('\ndone lol')

finally:
    adapter.stop()
