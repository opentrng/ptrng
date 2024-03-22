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
    def en(self):
        """The bit at index _i_ in the bitfield enables the RO number _i_"""
        rdata = self._rmap._if.read(self._rmap.RING_ADDR)
        return (rdata >> self._rmap.RING_EN_POS) & self._rmap.RING_EN_MSK

    @en.setter
    def en(self, val):
        rdata = self._rmap._if.read(self._rmap.RING_ADDR)
        rdata = rdata & (~(self._rmap.RING_EN_MSK << self._rmap.RING_EN_POS))
        rdata = rdata | (val << self._rmap.RING_EN_POS)
        self._rmap._if.write(self._rmap.RING_ADDR, rdata)


class _RegFreqcount:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def en(self):
        """Enable the frequency counter (active at `'1'`)"""
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        return (rdata >> self._rmap.FREQCOUNT_EN_POS) & self._rmap.FREQCOUNT_EN_MSK

    @en.setter
    def en(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        rdata = rdata & (~(self._rmap.FREQCOUNT_EN_MSK << self._rmap.FREQCOUNT_EN_POS))
        rdata = rdata | (val << self._rmap.FREQCOUNT_EN_POS)
        self._rmap._if.write(self._rmap.FREQCOUNT_ADDR, rdata)

    @property
    def start(self):
        """Write `'1'` to start the frequency counter measure"""
        return 0

    @start.setter
    def start(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        rdata = rdata & (~(self._rmap.FREQCOUNT_START_MSK << self._rmap.FREQCOUNT_START_POS))
        rdata = rdata | (val << self._rmap.FREQCOUNT_START_POS)
        self._rmap._if.write(self._rmap.FREQCOUNT_ADDR, rdata)

    @property
    def done(self):
        """This field is set to `'1'` when the measure is done and ready to be read"""
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        return (rdata >> self._rmap.FREQCOUNT_DONE_POS) & self._rmap.FREQCOUNT_DONE_MSK

    @property
    def select(self):
        """Select the index of the ring-oscillator for frequency measurement"""
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        return (rdata >> self._rmap.FREQCOUNT_SELECT_POS) & self._rmap.FREQCOUNT_SELECT_MSK

    @select.setter
    def select(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        rdata = rdata & (~(self._rmap.FREQCOUNT_SELECT_MSK << self._rmap.FREQCOUNT_SELECT_POS))
        rdata = rdata | (val << self._rmap.FREQCOUNT_SELECT_POS)
        self._rmap._if.write(self._rmap.FREQCOUNT_ADDR, rdata)

    @property
    def value(self):
        """Measured value (unit in cycles of the system clock)"""
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        return (rdata >> self._rmap.FREQCOUNT_VALUE_POS) & self._rmap.FREQCOUNT_VALUE_MSK

    @property
    def overflow(self):
        """Flag set to `'1'` if an overflow occurred during measurement"""
        rdata = self._rmap._if.read(self._rmap.FREQCOUNT_ADDR)
        return (rdata >> self._rmap.FREQCOUNT_OVERFLOW_POS) & self._rmap.FREQCOUNT_OVERFLOW_MSK


class _RegFreqdivider:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def value(self):
        """Clock divider value (1 means no division, 2 division by two, ...)"""
        rdata = self._rmap._if.read(self._rmap.FREQDIVIDER_ADDR)
        return (rdata >> self._rmap.FREQDIVIDER_VALUE_POS) & self._rmap.FREQDIVIDER_VALUE_MSK

    @value.setter
    def value(self, val):
        rdata = self._rmap._if.read(self._rmap.FREQDIVIDER_ADDR)
        rdata = rdata & (~(self._rmap.FREQDIVIDER_VALUE_MSK << self._rmap.FREQDIVIDER_VALUE_POS))
        rdata = rdata | (val << self._rmap.FREQDIVIDER_VALUE_POS)
        self._rmap._if.write(self._rmap.FREQDIVIDER_ADDR, rdata)


class _RegFifoctrl:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def clear(self):
        """Clear the FIFO"""
        return 0

    @clear.setter
    def clear(self, val):
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        rdata = rdata & (~(self._rmap.FIFOCTRL_CLEAR_MSK << self._rmap.FIFOCTRL_CLEAR_POS))
        rdata = rdata | (val << self._rmap.FIFOCTRL_CLEAR_POS)
        self._rmap._if.write(self._rmap.FIFOCTRL_ADDR, rdata)

    @property
    def empty(self):
        """Empty flag"""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_EMPTY_POS) & self._rmap.FIFOCTRL_EMPTY_MSK

    @property
    def full(self):
        """Full flag"""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_FULL_POS) & self._rmap.FIFOCTRL_FULL_MSK

    @property
    def almostempty(self):
        """Almost empty flag"""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_ALMOSTEMPTY_POS) & self._rmap.FIFOCTRL_ALMOSTEMPTY_MSK

    @property
    def almostfull(self):
        """Almost full flag"""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_ALMOSTFULL_POS) & self._rmap.FIFOCTRL_ALMOSTFULL_MSK


class _RegFifodata:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def data(self):
        """32 bits word from the PTRNG"""
        rdata = self._rmap._if.read(self._rmap.FIFODATA_ADDR)
        return (rdata >> self._rmap.FIFODATA_DATA_POS) & self._rmap.FIFODATA_DATA_MSK


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
    RING_EN_POS = 0
    RING_EN_MSK = 0xffffffff

    # FREQCOUNT - Frequency counter control register.
    FREQCOUNT_ADDR = 0x000c
    FREQCOUNT_EN_POS = 0
    FREQCOUNT_EN_MSK = 0x1
    FREQCOUNT_START_POS = 1
    FREQCOUNT_START_MSK = 0x1
    FREQCOUNT_DONE_POS = 2
    FREQCOUNT_DONE_MSK = 0x1
    FREQCOUNT_SELECT_POS = 3
    FREQCOUNT_SELECT_MSK = 0x1f
    FREQCOUNT_VALUE_POS = 8
    FREQCOUNT_VALUE_MSK = 0x7fffff
    FREQCOUNT_OVERFLOW_POS = 31
    FREQCOUNT_OVERFLOW_MSK = 0x1

    # FREQDIVIDER - Clock divider register, applies on oscillator RO0
    FREQDIVIDER_ADDR = 0x0010
    FREQDIVIDER_VALUE_POS = 0
    FREQDIVIDER_VALUE_MSK = 0xffffffff

    # FIFOCTRL - Control register for the FIFO to read the PTRNG random data output
    FIFOCTRL_ADDR = 0x0014
    FIFOCTRL_CLEAR_POS = 0
    FIFOCTRL_CLEAR_MSK = 0x1
    FIFOCTRL_EMPTY_POS = 1
    FIFOCTRL_EMPTY_MSK = 0x1
    FIFOCTRL_FULL_POS = 2
    FIFOCTRL_FULL_MSK = 0x1
    FIFOCTRL_ALMOSTEMPTY_POS = 3
    FIFOCTRL_ALMOSTEMPTY_MSK = 0x1
    FIFOCTRL_ALMOSTFULL_POS = 4
    FIFOCTRL_ALMOSTFULL_MSK = 0x1

    # FIFODATA - Data register for the FIFO to read the PTRNG random data output
    FIFODATA_ADDR = 0x0018
    FIFODATA_DATA_POS = 0
    FIFODATA_DATA_MSK = 0xffffffff

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
    def freqcount(self):
        """Frequency counter control register."""
        return self._if.read(self.FREQCOUNT_ADDR)

    @freqcount.setter
    def freqcount(self, val):
        self._if.write(self.FREQCOUNT_ADDR, val)

    @property
    def freqcount_bf(self):
        return _RegFreqcount(self)

    @property
    def freqdivider(self):
        """Clock divider register, applies on oscillator RO0"""
        return self._if.read(self.FREQDIVIDER_ADDR)

    @freqdivider.setter
    def freqdivider(self, val):
        self._if.write(self.FREQDIVIDER_ADDR, val)

    @property
    def freqdivider_bf(self):
        return _RegFreqdivider(self)

    @property
    def fifoctrl(self):
        """Control register for the FIFO to read the PTRNG random data output"""
        return self._if.read(self.FIFOCTRL_ADDR)

    @fifoctrl.setter
    def fifoctrl(self, val):
        self._if.write(self.FIFOCTRL_ADDR, val)

    @property
    def fifoctrl_bf(self):
        return _RegFifoctrl(self)

    @property
    def fifodata(self):
        """Data register for the FIFO to read the PTRNG random data output"""
        return self._if.read(self.FIFODATA_ADDR)

    @property
    def fifodata_bf(self):
        return _RegFifodata(self)
