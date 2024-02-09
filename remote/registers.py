#!/usr/bin/env python3
# -*- coding: utf-8 -*-

""" Created with Corsair v1.0.4

Control/status register map.
"""


class _RegId:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def uid(self):
        """Unique ID for OpenTRNG's PTRNG"""
        rdata = self._rmap._if.read(self._rmap.ID_ADDR)
        return (rdata >> self._rmap.ID_UID_POS) & self._rmap.ID_UID_MSK

    @property
    def rev(self):
        """Revision number"""
        rdata = self._rmap._if.read(self._rmap.ID_ADDR)
        return (rdata >> self._rmap.ID_REV_POS) & self._rmap.ID_REV_MSK


class _RegControl:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def reset(self):
        """Synchronous reset active to `'1'`"""
        return 0

    @reset.setter
    def reset(self, val):
        rdata = self._rmap._if.read(self._rmap.CONTROL_ADDR)
        rdata = rdata & (~(self._rmap.CONTROL_RESET_MSK << self._rmap.CONTROL_RESET_POS))
        rdata = rdata | (val << self._rmap.CONTROL_RESET_POS)
        self._rmap._if.write(self._rmap.CONTROL_ADDR, rdata)


class _RegRing:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def enable(self):
        """The bit at index _i_ in the bitfield enables the RO number _i_"""
        rdata = self._rmap._if.read(self._rmap.RING_ADDR)
        return (rdata >> self._rmap.RING_ENABLE_POS) & self._rmap.RING_ENABLE_MSK

    @enable.setter
    def enable(self, val):
        rdata = self._rmap._if.read(self._rmap.RING_ADDR)
        rdata = rdata & (~(self._rmap.RING_ENABLE_MSK << self._rmap.RING_ENABLE_POS))
        rdata = rdata | (val << self._rmap.RING_ENABLE_POS)
        self._rmap._if.write(self._rmap.RING_ADDR, rdata)


class _RegFreq:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def en(self):
        """Enable the frequency counter (active at `'1'`)"""
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        return (rdata >> self._rmap.FREQ_EN_POS) & self._rmap.FREQ_EN_MSK

    @en.setter
    def en(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        rdata = rdata & (~(self._rmap.FREQ_EN_MSK << self._rmap.FREQ_EN_POS))
        rdata = rdata | (val << self._rmap.FREQ_EN_POS)
        self._rmap._if.write(self._rmap.FREQ_ADDR, rdata)

    @property
    def start(self):
        """Write `'1'` to start the frequency counter measure"""
        return 0

    @start.setter
    def start(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        rdata = rdata & (~(self._rmap.FREQ_START_MSK << self._rmap.FREQ_START_POS))
        rdata = rdata | (val << self._rmap.FREQ_START_POS)
        self._rmap._if.write(self._rmap.FREQ_ADDR, rdata)

    @property
    def done(self):
        """This field is set to `'1'` when the measure is done and ready to be read"""
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        return (rdata >> self._rmap.FREQ_DONE_POS) & self._rmap.FREQ_DONE_MSK

    @property
    def select(self):
        """Select the index of the ring-oscillator for frequency measurement"""
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        return (rdata >> self._rmap.FREQ_SELECT_POS) & self._rmap.FREQ_SELECT_MSK

    @select.setter
    def select(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        rdata = rdata & (~(self._rmap.FREQ_SELECT_MSK << self._rmap.FREQ_SELECT_POS))
        rdata = rdata | (val << self._rmap.FREQ_SELECT_POS)
        self._rmap._if.write(self._rmap.FREQ_ADDR, rdata)

    @property
    def value(self):
        """Measured value (unit in cycles of the system clock)"""
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        return (rdata >> self._rmap.FREQ_VALUE_POS) & self._rmap.FREQ_VALUE_MSK

    @property
    def overflow(self):
        """Flag set to `'1'` if an overflow occurred during measurement"""
        rdata = self._rmap._if.read(self._rmap.FREQ_ADDR)
        return (rdata >> self._rmap.FREQ_OVERFLOW_POS) & self._rmap.FREQ_OVERFLOW_MSK


class RegMap:
    """Control/Status register map"""

    # ID - OpenTRNG's PTRNG identification register for UID and revision number.
    ID_ADDR = 0x0000
    ID_UID_POS = 0
    ID_UID_MSK = 0xffff
    ID_REV_POS = 16
    ID_REV_MSK = 0xffff

    # CONTROL - Global control register for the OpenTRNG's PTRNG
    CONTROL_ADDR = 0x0004
    CONTROL_RESET_POS = 0
    CONTROL_RESET_MSK = 0x1

    # RING - Ring-oscillator enable register (enable bits are active at `'1'`).
    RING_ADDR = 0x0008
    RING_ENABLE_POS = 0
    RING_ENABLE_MSK = 0xffffffff

    # FREQ - Frequency counter control register.
    FREQ_ADDR = 0x000c
    FREQ_EN_POS = 0
    FREQ_EN_MSK = 0x1
    FREQ_START_POS = 1
    FREQ_START_MSK = 0x1
    FREQ_DONE_POS = 2
    FREQ_DONE_MSK = 0x1
    FREQ_SELECT_POS = 3
    FREQ_SELECT_MSK = 0x1f
    FREQ_VALUE_POS = 8
    FREQ_VALUE_MSK = 0x7fffff
    FREQ_OVERFLOW_POS = 31
    FREQ_OVERFLOW_MSK = 0x1

    def __init__(self, interface):
        self._if = interface

    @property
    def id(self):
        """OpenTRNG's PTRNG identification register for UID and revision number."""
        return self._if.read(self.ID_ADDR)

    @property
    def id_bf(self):
        return _RegId(self)

    @property
    def control(self):
        """Global control register for the OpenTRNG's PTRNG"""
        return 0

    @control.setter
    def control(self, val):
        self._if.write(self.CONTROL_ADDR, val)

    @property
    def control_bf(self):
        return _RegControl(self)

    @property
    def ring(self):
        """Ring-oscillator enable register (enable bits are active at `'1'`)."""
        return self._if.read(self.RING_ADDR)

    @ring.setter
    def ring(self, val):
        self._if.write(self.RING_ADDR, val)

    @property
    def ring_bf(self):
        return _RegRing(self)

    @property
    def freq(self):
        """Frequency counter control register."""
        return self._if.read(self.FREQ_ADDR)

    @freq.setter
    def freq(self, val):
        self._if.write(self.FREQ_ADDR, val)

    @property
    def freq_bf(self):
        return _RegFreq(self)
