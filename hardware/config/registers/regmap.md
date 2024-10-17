# PTRNG register map

Created with [Corsair](https://github.com/esynr3z/corsair) v1.0.4.

## Conventions

| Access mode | Description               |
| :---------- | :------------------------ |
| rw          | Read and Write            |
| rw1c        | Read and Write 1 to Clear |
| rw1s        | Read and Write 1 to Set   |
| ro          | Read Only                 |
| roc         | Read Only to Clear        |
| roll        | Read Only / Latch Low     |
| rolh        | Read Only / Latch High    |
| wo          | Write only                |
| wosc        | Write Only / Self Clear   |

## Register map summary

Base address: 0x00000000

| Name                     | Address    | Description |
| :---                     | :---       | :---        |
| [ID](#id)                | 0x0000     | OpenTRNG's PTRNG identification register for UID and revision number. |
| [CONTROL](#control)      | 0x0004     | Global control register for the OpenTRNG's PTRNG |
| [RING](#ring)            | 0x0008     | Ring-oscillator enable register (enable bits are active at `'1'`). |
| [FREQCOUNT](#freqcount)  | 0x000c     | Frequency counter control register. |
| [FREQDIVIDER](#freqdivider) | 0x0010     | Clock divider register, applies on oscillator RO0 |
| [ALARM](#alarm)          | 0x0014     | Register for the total failure alarm. |
| [FIFOCTRL](#fifoctrl)    | 0x0018     | Control register for the FIFO, into read the PTRNG random data output |
| [FIFODATA](#fifodata)    | 0x001c     | Data register for the FIFO to read the PTRNG random data output |

## ID

OpenTRNG's PTRNG identification register for UID and revision number.

Address offset: 0x0000

Reset value: 0x0001cea3


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| REV              | 31:16  | ro              | 0x0001     | Revision number |
| UID              | 15:0   | ro              | 0xcea3     | Unique ID for OpenTRNG's PTRNG |

Back to [Register map](#register-map-summary).

## CONTROL

Global control register for the OpenTRNG's PTRNG

Address offset: 0x0004

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| -                | 31:1   | -               | 0x0000000  | Reserved |
| RESET            | 0      | wosc            | 0x0        | Synchronous reset active to `'1'` |

Back to [Register map](#register-map-summary).

## RING

Ring-oscillator enable register (enable bits are active at `'1'`).

Address offset: 0x0008

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| EN               | 31:0   | rw              | 0x00000000 | The bit at index _i_ in the bitfield enables the RO number _i_ |

Back to [Register map](#register-map-summary).

## FREQCOUNT

Frequency counter control register.

Address offset: 0x000c

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| OVERFLOW         | 31     | ro              | 0x0        | Flag set to `'1'` if an overflow occurred during measurement |
| VALUE            | 30:8   | ro              | 0x00000    | Measured value (unit in cycles of the system clock) |
| SELECT           | 7:3    | rw              | 0x0        | Select the index of the ring-oscillator for frequency measurement |
| DONE             | 2      | ro              | 0x0        | This field is set to `'1'` when the measure is done and ready to be read |
| START            | 1      | wosc            | 0x0        | Write `'1'` to start the frequency counter measure |
| EN               | 0      | rw              | 0x0        | Enable the frequency counter (active at `'1'`) |

Back to [Register map](#register-map-summary).

## FREQDIVIDER

Clock divider register, applies on oscillator RO0

Address offset: 0x0010

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| VALUE            | 31:0   | rw              | 0x00000000 | Clock divider value (1 means no division, 2 division by two, ...) |

Back to [Register map](#register-map-summary).

## ALARM

Register for the total failure alarm.

Address offset: 0x0014

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| -                | 31:17  | -               | 0x000      | Reserved |
| DETECTED         | 16     | roc             | 0x0        | This signal is triggered to '1' in the event of a total failure alarm, the alarm is cleared on read. |
| THRESHOLD        | 15:0   | rw              | 0x0000     | Threshold value for triggering the total failure alarm. The threshold is compared to a counter, alarm is triggered when the counter greater or equal than the threshold. The counting method depends on the digitizer (ERO/MURO/COSO...) |

Back to [Register map](#register-map-summary).

## FIFOCTRL

Control register for the FIFO, into read the PTRNG random data output

Address offset: 0x0018

Reset value: 0x00000002


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| -                | 31:23  | -               | 0x00       | Reserved |
| BURSTSIZE        | 22:7   | ro              | 0x0000     | Size of a burst (in count of 32bit words) |
| RDBURSTAVAILABLE | 6      | ro              | 0x0        | Valid to '1' when a burst is available for read (see BURSTSIZE) |
| ALMOSTFULL       | 5      | ro              | 0x0        | Almost full flag |
| ALMOSTEMPTY      | 4      | ro              | 0x0        | Almost empty flag |
| FULL             | 3      | ro              | 0x0        | Full flag |
| EMPTY            | 2      | ro              | 0x0        | Empty flag |
| PACKBITS         | 1      | rw              | 0x1        | Pack LSBs from each IRN into 32bits words (LSB to be read first); else all 32bits of IRN are written into the FIFO. |
| CLEAR            | 0      | wosc            | 0x0        | Clear the FIFO |

Back to [Register map](#register-map-summary).

## FIFODATA

Data register for the FIFO to read the PTRNG random data output

Address offset: 0x001c

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| DATA             | 31:0   | ro              | 0x00000000 | 32 bits word from the PTRNG |

Back to [Register map](#register-map-summary).
