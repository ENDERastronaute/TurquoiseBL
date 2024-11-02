
SRC_DIR := src
BUILD_DIR := build

SOURCES = $(wildcard $(SRC_DIR)/*.c)

OBJ = $(SOURCES:.c=.o)

IMAGE := out/turquoisebl.img

run : gpt
		qemu-system-x86_64 -L /usr/share/edk2-ovmf/ -pflash /home/ender/OVMF.fd -hda out/turquoisebl.bin

iso : cp
		xorriso -as mkisofs -R -f -e turquoisebl.img -no-emul-boot -o turquoisebl.iso iso

cp : fat
		cp out/turquoisebl.img iso
		cp build/BOOTX64.EFI iso/EFI/BOOT

gpt : fat
		mkgpt -o out/turquoisebl.bin --image-size 4096 --part $(IMAGE) --type system

fat : boot_dir
		mcopy -i $(IMAGE) build/BOOTX64.EFI ::/EFI/BOOT

boot_dir : efi_dir
		mmd -i $(IMAGE) ::/EFI/BOOT

efi_dir : format
		mmd -i $(IMAGE) ::/EFI

format : $(IMAGE)
		mformat -i $< -f 1440 ::

out/turquoisebl.img : build/BOOTX64.EFI
		dd if=/dev/zero of=out/turquoisebl.img bs=1k count=1440

build/BOOTX64.EFI : src/data.o $(OBJ)
		x86_64-w64-mingw32-gcc -nostdlib -Wl,-dll -shared -Wl,--subsystem,10 -e efi_main -o $@ $^

src/data.o : /home/ender/gnu-efi/lib/data.c
		x86_64-w64-mingw32-gcc -ffreestanding -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol -c -o $@ $<	

%.o : %.c
		x86_64-w64-mingw32-gcc -ffreestanding -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol -c -o $@ $<

clean :
		rm src/*.o out/* build/* iso/* iso/EFI/BOOT/* *.iso
