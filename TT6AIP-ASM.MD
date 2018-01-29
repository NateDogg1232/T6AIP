# Assembler documentation

## Introduction

This assembler's goal is to implement a simple syntax while maintaining a capable platform to use.

## Usage

### Initial screen

```
Welcome to T6AIP-ASM
-
```

On the screen will be displayed a prompt (`-`). Per this, one may enter commands


### Commands

- `I (File)` - Sets input file
- `O (File)` - Sets output file
- `A` - Assemble
- `H` - Help
- `Q` - Quit


## Language

### Directives

All directives start with '.'

- `.define (symbol) (value)`
  - Defines a symbol which, in every occurance in the code will be replaced with (value)
- `.bank (bank no.)`
  - Sets the currently operating bank
- `.db (Byte)`
  - Adds a byte value to the program
- `.inc "(File)"`
  - Includes a file as pure ASM (When processing, it will push this file right where the inc tag is)
- `.incbin "(File)"`
  - Includes a binary file

