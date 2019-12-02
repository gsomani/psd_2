#!/bin/bash

HEX=imem.hex

OBJ=test.o

MEM=memory.mem

TOOLCHAIN_PREFIX=riscv32-unknown-elf

$TOOLCHAIN_PREFIX-gcc -o $OBJ -c $1 -march=rv32i -mabi=ilp32

$TOOLCHAIN_PREFIX-objdump -d -w $OBJ | sed '1,5d' | awk '!/:$/ { print $2; }' | sed '/^$/d' > $HEX;

gcc -o hex_bin.out hex_to_bin.c 

./hex_bin.out $HEX $MEM

rm $HEX $OBJ hex_bin.out

