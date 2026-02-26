# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer


async def write_config(dut, pulse_count, h_pol, v_pol, h_display, h_front, h_sync, h_back, v_display, v_bottom, v_sync, v_top):
    data = ((pulse_count << 69) | (h_pol << 68) | (v_pol << 67) | 
            (h_display << 56) | (h_front << 47) | (h_sync << 38) | (h_back << 29) |
            (v_display << 18) | (v_bottom << 12) | (v_sync << 6) | v_top)
    
    for i in range(75):
        dut.cfg_dat.value = 1 if (data & (1 << 74)) else 0
        await ClockCycles(dut.clk, 2)
        dut.cfg_clk.value = 1
        await ClockCycles(dut.clk, 2)
        dut.cfg_clk.value = 0
        data <<= 1
    
    await ClockCycles(dut.clk, 4)

async def expect_read_cmd(dut, addr):
    assert dut.qspi_cs.value == 1
    await FallingEdge(dut.qspi_cs)

    assert dut.qspi_mosi.value == 0
    
    cmd = 0xED
    for i in range(8):
        await ClockCycles(dut.qspi_clk, 1)
        assert dut.qspi_mosi.value == (1 if cmd & 0x80 else 0)
        assert dut.qspi_cs.value == 0
        assert dut.uio_oe.value == (0b11000111 if dut.qspi_pinout.value else 0b11001011)
        cmd <<= 1

    for i in range(4):
        await RisingEdge(dut.qspi_clk)
        assert dut.qspi_mosi.value == (addr & 0xF00000) >> 20
        assert dut.qspi_cs.value == 0
        assert dut.uio_oe.value == (0b11111111 if dut.qspi_pinout.value else 0b11111111)
        addr <<= 4
        await FallingEdge(dut.qspi_clk)
        assert dut.qspi_mosi.value == (addr & 0xF00000) >> 20
        assert dut.qspi_cs.value == 0
        assert dut.uio_oe.value == (0b11111111 if dut.qspi_pinout.value else 0b11111111)
        addr <<= 4

    for i in range(7):
        await ClockCycles(dut.qspi_clk, 1)
        assert dut.qspi_cs.value == 0
        assert dut.uio_oe.value == (0b11000011 if dut.qspi_pinout.value else 0b11001001)

    await FallingEdge(dut.qspi_clk)

async def qspi_send_byte(dut, data):
    assert dut.qspi_cs.value == 0

    await Timer(1, "ns")
    dut.qspi_miso_in.value = (data >> 4) & 0xF
    assert dut.uio_oe.value == (0b11000011 if dut.qspi_pinout.value else 0b11001001)
    assert dut.qspi_cs.value == 0
    await RisingEdge(dut.qspi_clk)
    await Timer(1, "ns")
    dut.qspi_miso_in.value = data & 0xF
    assert dut.uio_oe.value == (0b11000011 if dut.qspi_pinout.value else 0b11001001)
    assert dut.qspi_cs.value == 0
    await FallingEdge(dut.qspi_clk)

async def start_640x480(dut):
    dut._log.info("Start")

    # Set the clock period to 40 ns (25 MHz)
    clock = Clock(dut.clk, 40, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.cfg_clk.value = 0
    dut.cfg_dat.value = 0
    dut.display_en.value = 0
    dut.qspi_pinout.value = 0
    dut.qspi_half_clk.value = 0
    dut.qspi_latency.value = 1
    dut.addr_hi.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Programming 640x480 mode")

    assert dut.qspi_cs.value == 1

    # Feed in 640x480 VGA config
    await write_config(dut, 41, 1, 1, 639, 15, 95, 47, 479, 9, 1, 32)

    dut._log.info("Enabling display")

    dut.display_en.value = 1
    await ClockCycles(dut.clk, 2)

@cocotb.test()
async def test_sync(dut):
    await start_640x480(dut)

    # Test sync
    vsync = 1
    for i in range(525*2+5):
        for j in range(48):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            await ClockCycles(dut.clk, 1)
        vsync = 0 if i % 525 in (480+10+33-1, 480+10+33) else 1
        for j in range(640+16):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            await ClockCycles(dut.clk, 1)
        for j in range(96):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            await ClockCycles(dut.clk, 1)

@cocotb.test()
async def test_data(dut):
    await start_640x480(dut)

    for i in range(10):
        # Wait for data read begin
        await expect_read_cmd(dut, 320*(i//2))

        # Send pixel data
        for i in range(320):
            await qspi_send_byte(dut, (i+15) & 0xff)
        
        await RisingEdge(dut.qspi_cs)
