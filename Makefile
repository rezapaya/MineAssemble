# Build flat binary

bin/mineassemble.bin: bin src/link.ld bin/init.o bin/interrupts.o bin/vga.o bin/main.o bin/reference.o bin/textures.o bin/cmath.o bin/splash.o bin/world.o bin/player.o bin/input.o bin/graphics.o bin/globals.o
	ld -m elf_i386 -T src/link.ld -o bin/mineassemble.bin bin/init.o bin/interrupts.o bin/vga.o bin/main.o bin/reference.o bin/textures.o bin/cmath.o bin/splash.o bin/world.o bin/player.o bin/input.o bin/graphics.o bin/globals.o

bin/reference.o: src/reference.c
	gcc -m32 -c -g -o bin/reference.o src/reference.c -std=c99 -ffreestanding -Ofast -nostdlib -nostdinc -fno-builtin -nostartfiles -nodefaultlibs -fno-exceptions -fno-stack-protector -static -fno-pic

bin/%.o: src/%.asm
	nasm -felf -o $@ $< -isrc/

bin:
	mkdir -p bin

# Test in QEMU

test: bin/mineassemble.bin
	qemu-system-i386 -kernel bin/mineassemble.bin

.PHONY: test

# Target for producing ISO image

iso: mineassemble.iso
mineassemble.iso: bin/mineassemble.bin
	cp bin/mineassemble.bin iso/boot/mineassemble.bin
	grub-mkrescue -o mineassemble.iso iso

.PHONY: iso

# Clean up

clean:
	rm -rf bin
