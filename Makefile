# Makefile for Hello World OS on ARM example

all: kernel.elf

LINKER=
CXX=aarch64-linux-gnu-g++
CC= aarch64-linux-gnu-gcc
LD= aarch64-linux-gnu-ld
CFLAGS= -g -pedantic -Wall -Wextra -fPIC -std=gnu2x


LDFLAGS= -g -N -Ttext=0x10000
ASMFLAGS= -g

CSRC= kernel.c queue.c process.c
ASMSRC= boot.S box.S process_asm.S

KERNEL= kernel
COBJ=$(patsubst %.c,%.o,$(CSRC)) 
ASMOBJ=$(patsubst %.S,%.o,$(ASMSRC))
ALLOBJ=$(COBJ) $(ASMOBJ) 
OSLIB=libos.a
OSASMOBJ=$(patsubst %.S,%.o,$(OSASMSRC))
OSCOBJ=$(patsubst %.c,%.o,$(OSCSRC)) 

$(KERNEL).elf: $(LINKER_FILE) $(COBJ) $(ASMOBJ) $(OSLIB) 
	$(LD) $(LDFLAGS) -o $@  $(COBJ) $(ASMOBJ) $(OSLIB)

$(COBJ): %.o: %.c
	$(CC) $(CFLAGS) -MMD -c $< -o $@	

$(ASMOBJ): %.o: %.S
	$(CC) $(ASMFLAGS) -MMD -c $< -o $@

.PHONY: clean run debug

run:
	qemu-system-aarch64 -machine raspi3b   -kernel kernel.elf

debug:
	qemu-system-aarch64 -machine raspi3b  -S -s -kernel kernel.elf &
	ddd --debugger 'gdb-multiarch -ex "target remote localhost:1234" -ex "break main" -ex "continue"' kernel.elf

clean:
	rm *.o *.elf  *.d

compress:
	/bin/bash -c 'dd=`basename $$(pwd)`; cd ..; tar -zcf $$dd.tar.gz $$dd'
