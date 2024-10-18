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


class _RegAlarm:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def threshold(self):
        """Threshold value for triggering the total failure alarm. The threshold is compared to a counter, alarm is triggered when the counter greater or equal than the threshold. The counting method depends on the digitizer (ERO/MURO/COSO...)"""
        rdata = self._rmap._if.read(self._rmap.ALARM_ADDR)
        return (rdata >> self._rmap.ALARM_THRESHOLD_POS) & self._rmap.ALARM_THRESHOLD_MSK

    @threshold.setter
    def threshold(self, val):
        rdata = self._rmap._if.read(self._rmap.ALARM_ADDR)
        rdata = rdata & (~(self._rmap.ALARM_THRESHOLD_MSK << self._rmap.ALARM_THRESHOLD_POS))
        rdata = rdata | (val << self._rmap.ALARM_THRESHOLD_POS)
        self._rmap._if.write(self._rmap.ALARM_ADDR, rdata)

    @property
    def detected(self):
        """This signal is triggered to '1' in the event of a total failure alarm, the alarm is cleared on read."""
        rdata = self._rmap._if.read(self._rmap.ALARM_ADDR)
        return (rdata >> self._rmap.ALARM_DETECTED_POS) & self._rmap.ALARM_DETECTED_MSK


class _RegOnlinetest:
    def __init__(self, rmap):
        self._rmap = rmap

    @property
    def average(self):
        """Average expected value for the online test."""
        rdata = self._rmap._if.read(self._rmap.ONLINETEST_ADDR)
        return (rdata >> self._rmap.ONLINETEST_AVERAGE_POS) & self._rmap.ONLINETEST_AVERAGE_MSK

    @average.setter
    def average(self, val):
        rdata = self._rmap._if.read(self._rmap.ONLINETEST_ADDR)
        rdata = rdata & (~(self._rmap.ONLINETEST_AVERAGE_MSK << self._rmap.ONLINETEST_AVERAGE_POS))
        rdata = rdata | (val << self._rmap.ONLINETEST_AVERAGE_POS)
        self._rmap._if.write(self._rmap.ONLINETEST_ADDR, rdata)

    @property
    def drift(self):
        """Maximum drift between the expected value and the actual value for the online tests."""
        rdata = self._rmap._if.read(self._rmap.ONLINETEST_ADDR)
        return (rdata >> self._rmap.ONLINETEST_DRIFT_POS) & self._rmap.ONLINETEST_DRIFT_MSK

    @drift.setter
    def drift(self, val):
        rdata = self._rmap._if.read(self._rmap.ONLINETEST_ADDR)
        rdata = rdata & (~(self._rmap.ONLINETEST_DRIFT_MSK << self._rmap.ONLINETEST_DRIFT_POS))
        rdata = rdata | (val << self._rmap.ONLINETEST_DRIFT_POS)
        self._rmap._if.write(self._rmap.ONLINETEST_ADDR, rdata)

    @property
    def valid(self):
        """This signal is fallen to '0' when the online test becomes invalid, must be manually cleared."""
        rdata = self._rmap._if.read(self._rmap.ONLINETEST_ADDR)
        return (rdata >> self._rmap.ONLINETEST_VALID_POS) & self._rmap.ONLINETEST_VALID_MSK

    @property
    def clear(self):
        """This signal clears the 'valid' signal back to '1'."""
        return 0

    @clear.setter
    def clear(self, val):
        rdata = self._rmap._if.read(self._rmap.ONLINETEST_ADDR)
        rdata = rdata & (~(self._rmap.ONLINETEST_CLEAR_MSK << self._rmap.ONLINETEST_CLEAR_POS))
        rdata = rdata | (val << self._rmap.ONLINETEST_CLEAR_POS)
        self._rmap._if.write(self._rmap.ONLINETEST_ADDR, rdata)


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
    def packbits(self):
        """Pack LSBs from each IRN into 32bits words (LSB to be read first); else all 32bits of IRN are written into the FIFO."""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_PACKBITS_POS) & self._rmap.FIFOCTRL_PACKBITS_MSK

    @packbits.setter
    def packbits(self, val):
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        rdata = rdata & (~(self._rmap.FIFOCTRL_PACKBITS_MSK << self._rmap.FIFOCTRL_PACKBITS_POS))
        rdata = rdata | (val << self._rmap.FIFOCTRL_PACKBITS_POS)
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

    @property
    def rdburstavailable(self):
        """Valid to '1' when a burst is available for read (see BURSTSIZE)"""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_RDBURSTAVAILABLE_POS) & self._rmap.FIFOCTRL_RDBURSTAVAILABLE_MSK

    @property
    def burstsize(self):
        """Size of a burst (in count of 32bit words)"""
        rdata = self._rmap._if.read(self._rmap.FIFOCTRL_ADDR)
        return (rdata >> self._rmap.FIFOCTRL_BURSTSIZE_POS) & self._rmap.FIFOCTRL_BURSTSIZE_MSK


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

    # ALARM - Register for the total failure alarm.
    ALARM_ADDR = 0x0014
    ALARM_THRESHOLD_POS = 0
    ALARM_THRESHOLD_MSK = 0xffff
    ALARM_DETECTED_POS = 16
    ALARM_DETECTED_MSK = 0x1

    # ONLINETEST - Register for online testing.
    ONLINETEST_ADDR = 0x0018
    ONLINETEST_AVERAGE_POS = 0
    ONLINETEST_AVERAGE_MSK = 0xffff
    ONLINETEST_DRIFT_POS = 16
    ONLINETEST_DRIFT_MSK = 0x3fff
    ONLINETEST_VALID_POS = 30
    ONLINETEST_VALID_MSK = 0x1
    ONLINETEST_CLEAR_POS = 31
    ONLINETEST_CLEAR_MSK = 0x1

    # FIFOCTRL - Control register for the FIFO, into read the PTRNG random data output
    FIFOCTRL_ADDR = 0x001c
    FIFOCTRL_CLEAR_POS = 0
    FIFOCTRL_CLEAR_MSK = 0x1
    FIFOCTRL_PACKBITS_POS = 1
    FIFOCTRL_PACKBITS_MSK = 0x1
    FIFOCTRL_EMPTY_POS = 2
    FIFOCTRL_EMPTY_MSK = 0x1
    FIFOCTRL_FULL_POS = 3
    FIFOCTRL_FULL_MSK = 0x1
    FIFOCTRL_ALMOSTEMPTY_POS = 4
    FIFOCTRL_ALMOSTEMPTY_MSK = 0x1
    FIFOCTRL_ALMOSTFULL_POS = 5
    FIFOCTRL_ALMOSTFULL_MSK = 0x1
    FIFOCTRL_RDBURSTAVAILABLE_POS = 6
    FIFOCTRL_RDBURSTAVAILABLE_MSK = 0x1
    FIFOCTRL_BURSTSIZE_POS = 7
    FIFOCTRL_BURSTSIZE_MSK = 0xffff

    # FIFODATA - Data register for the FIFO to read the PTRNG random data output
    FIFODATA_ADDR = 0x0020
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
    def alarm(self):
        """Register for the total failure alarm."""
        return self._if.read(self.ALARM_ADDR)

    @alarm.setter
    def alarm(self, val):
        self._if.write(self.ALARM_ADDR, val)

    @property
    def alarm_bf(self):
        return _RegAlarm(self)

    @property
    def onlinetest(self):
        """Register for online testing."""
        return self._if.read(self.ONLINETEST_ADDR)

    @onlinetest.setter
    def onlinetest(self, val):
        self._if.write(self.ONLINETEST_ADDR, val)

    @property
    def onlinetest_bf(self):
        return _RegOnlinetest(self)

    @property
    def fifoctrl(self):
        """Control register for the FIFO, into read the PTRNG random data output"""
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
