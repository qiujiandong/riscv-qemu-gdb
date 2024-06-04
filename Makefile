TOOLPEFIX ?= riscv64-unknown-elf-
FLAGS = -march=rv64imac -mabi=lp64

AS := $(TOOLPEFIX)as
CC := $(TOOLPEFIX)gcc
LD := $(TOOLPEFIX)ld
OBJCOPY := $(TOOLPEFIX)objcopy

.PHONY: all
all: kernel/hello.bin kernel/.gdbinit user/hello.elf user/.gdbinit

kernel/hello.o: kernel/hello.s
	$(AS) $(FLAGS) -g -o $@ $<

kernel/hello.elf: kernel/hello.ld kernel/hello.o
	$(LD) -T $< -o $@ kernel/hello.o

kernel/hello.bin: kernel/hello.elf
	$(OBJCOPY) $< -O binary $@

user/hello.elf: user/hello.c
	$(CC) $(FLAGS) -g -o $@ $<

.PHONY: kernel-clean
kernel-clean:
	rm -f kernel/hello.elf kernel/hello.bin kernel/hello.o kernel/.gdbinit

.PHONY: user-clean
user-clean:
	rm -f user/hello.elf user/.gdbinit

.PHONY: clean
clean: kernel-clean user-clean

# run hello in kernel mode
.PHONY: qemu-kernel
qemu-kernel : kernel/hello.bin
	@echo "Exit with Ctrl-A + X"
	qemu-system-riscv64 -M virt -nographic -bios $<

# generate .gdbinit for debug
kernel/.gdbinit: .gdbinit.tmpl
	sed -e 's/%binary%/hello.elf/g' -e '$$abreak *0x80000000' < $< > $@

# run hello in kernel mode and debug
.PHONY: qemu-kernel-debug
qemu-kernel-debug : kernel/hello.bin kernel/.gdbinit
	@echo "Exit with Ctrl-A + X"
	qemu-system-riscv64 -M virt -nographic -bios $< -S -s

# run hello in user mode
.PHONY: qemu-user
qemu-user : user/hello.elf
	qemu-riscv64 $<

# generate .gdbinit for debug
user/.gdbinit: .gdbinit.tmpl
	sed -e 's/%binary%/hello.elf/g' < $< > $@

# run hello in user mode and debug
.PHONY: qemu-user-debug
qemu-user-debug : user/hello.elf user/.gdbinit
	qemu-riscv64 -g 1234 $<
