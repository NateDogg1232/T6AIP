# Interpreter documentation

## Specs

- 26k of RAM
- Up to 256k of program mem
- Pure TTY terminal, no inherent backspace support

# Note: Redo memmap

## Memory map

- `$0000 - $6799` - RAM
- `$7800 - $B799` - Program page 0
- `$B800 - $F799` - Loaded program page
- `$F800 - $FFF9` - I/O Registers
- `$FFFA - $FFFF` - Interrupt vectors

## Program File Structure

- Header:
  - Byte 0:
  - Byte 1: Number of pages in the program
  - Byte 2-x: Address of page/16KB
  
  
- Structure:
  - Header
  - Program page 0
  - Other data

