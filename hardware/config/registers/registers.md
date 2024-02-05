# OpenTRNG entropy source register map

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
| [ID](#id)                | 0x0000     | Entropy source identification register for UID and revision number. |
| [CONTROL](#control)      | 0x0004     | Global control register for the entropy source |
| [RING](#ring)            | 0x0008     | Ring-oscillator enable register (enable bits are active at `'1'`). |
| [FREQCOUNT](#freqcount)  | 0x000c     | Frequency counter control register. |

## ID

Entropy source identification register for UID and revision number.

Address offset: 0x0000

Reset value: 0x0001cea3


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| REV              | 31:16  | ro              | 0x0001     | Revision number |
| UID              | 15:0   | ro              | 0xcea3     | Unique ID for OpenTRNG entropy source |

Back to [Register map](#register-map-summary).

## CONTROL

Global control register for the entropy source

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
| ENABLE           | 31:0   | rw              | 0x00000000 | The bit at index _i_ in the bitfield enables the RO number _i_ |

Back to [Register map](#register-map-summary).

## FREQCOUNT

Frequency counter control register.

Address offset: 0x000c

Reset value: 0x00000000


| Name             | Bits   | Mode            | Reset      | Description |
| :---             | :---   | :---            | :---       | :---        |
| OVERFLOW         | 31     | ro              | 0x0        | Flag set to `'1'` if an overflow occurred during measurement |
| RESULT           | 30:8   | ro              | 0x00000    | Measured value (unit in cycles of the system clock) |
| SELECT           | 7:3    | rw              | 0x0        | Select the index of the ring-oscillator for frequency measurement |
| DONE             | 2      | ro              | 0x0        | This field is set to `'1'` when the measure is done and ready to be read |
| START            | 1      | wosc            | 0x0        | Write `'1'` to start the frequency counter measure |
| EN               | 0      | rw              | 0x0        | Enable the frequency counter (active at `'1'`) |

Back to [Register map](#register-map-summary).
