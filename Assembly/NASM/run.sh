#!/usr/bin/env bash
set -euo pipefail

# Build and run the NASM dice program (Linux, 32-bit)
# Requires: nasm, gcc with 32-bit libs (multilib), libc

asm=dice.asm
obj=dice.o
bin=dice

# Assemble
nasm -f elf32 "$asm" -o "$obj"

# Link
gcc -m32 "$obj" -o "$bin"

# Ensure terminal resets even on interrupt
cleanup() { stty sane || true; }
trap cleanup EXIT INT

# Run
./"$bin"
