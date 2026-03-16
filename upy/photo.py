# Script to run the photo frame.
# Should probably be adapted to use the regular SDK.

from time import sleep_us
from ttcontrol import *

latency = 3
write_ui_in(latency << 4)
enable_ui_in(True)

# TODO Select design
#select_design(nnn)

#set_clock_hz(50000000, max_rp2040_freq=230000000)  # 640x480 full
#set_clock_hz(74000000, max_rp2040_freq=230000000)  # 720p60 half
#set_clock_hz(121000000, max_rp2040_freq=250000000)  # 720p50 full
#set_clock_hz(65000000, max_rp2040_freq=250000000)   # 1024x768 half
set_clock_hz(125000000, max_rp2040_freq=250000000)  # 1024x768 full
#set_clock_hz(115000000, max_rp2040_freq=230000000) # 1080p60 half
reset_project()

def write_config(h_pol, v_pol, h_display, h_front, h_sync, h_back, v_display, v_bottom, v_sync, v_top):
    pulse_count = 40 + latency - 2
    h_display -= 1
    h_front -= 1
    h_sync -= 1
    h_back -= 1
    v_display -= 1
    v_bottom -= 1
    v_sync -= 1
    v_top -= 1
    data = ((pulse_count << 62) | (h_pol << 61) | (v_pol << 60) | 
            ((h_display >> 3) << 51) | ((h_front >> 2) << 43) | ((h_sync >> 2) << 35) | ((h_back >> 2) << 27) |
            ((v_display >> 2) << 18) | (v_bottom << 12) | (v_sync << 6) | v_top)
    
    ui_in[7].off()
    sleep_us(1)

    for i in range(68):
        ui_in[1].value(1 if (data & (1 << 67)) else 0)
        sleep_us(1)
        ui_in[0].on()
        sleep_us(1)
        ui_in[0].off()
        data <<= 1

def write_qspi_config(addr, full_res, dither):
    data = (dither << 8) | (full_res << 7) | addr
    
    ui_in[7].on()
    sleep_us(1)

    for i in range(9):
        ui_in[1].value(1 if (data & (1 << 8)) else 0)
        sleep_us(1)
        ui_in[0].on()
        sleep_us(1)
        ui_in[0].off()
        data <<= 1
    
    ui_in[7].off()
    
#write_config(1, 1, 640, 16, 96, 48, 480, 10, 2, 33)           # 640x480
#write_config(1, 1, 640*2, 16*2, 96*2, 48*2, 480, 10, 2, 33)   # 640x480 full
#write_config(0, 1, 1024, 24, 136, 160, 768, 3, 6, 29)         # 1024x768
#write_config(0, 1, 1024*2, 24*2, 136*2, 160*2, 768, 3, 6, 29) # 1024x768 full
write_config(0, 1, 1024*2, 48*2, 104*2, 152*2, 768, 3, 4, 23) # 1024x768 full
#write_config(1, 1, 1280, 110, 40, 220, 720, 5, 5, 20)         # 720p
#write_config(0, 1, 1280*2, 48*2, 128*2, 176*2, 720, 3, 5, 16) # 720p full
#write_config(0, 1, 1920, 48, 32, 80, 1080, 3, 5, 18)          # 1080p
write_qspi_config(24, 1, 1)

ui_in[2].on()
