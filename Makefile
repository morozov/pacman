Pac-Man.scl: Pac-Man.trd
	trd2scl Pac-Man.trd Pac-Man.scl

# The compressed screen is created by Laser Compact v5.2
# and cannot be generated at the build time
# see https://spectrumcomputing.co.uk/?cat=96&id=21446
Pac-Man.trd: boot.$$B hob/screenz.$$C data.$$C
	createtrd Pac-Man.trd
	hobeta2trd boot.\$$B Pac-Man.trd
	hobeta2trd hob/screenz.\$$C Pac-Man.trd
	hobeta2trd data.\$$C Pac-Man.trd

	# Write the correct length to the first file (offset 13)
	# The lenth is 1 (boot) + 8 (loading screen) + 37 (data) = 46
	# Got to use the the octal notation since it's the only format of binary data POSIX printf understands
	# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html#tag_20_94_13
	printf '\056' | dd of=Pac-Man.trd bs=1 seek=13 conv=notrunc status=none

	# Remove two other files (fill 2×16 bytes starting offset 16 with zeroes)
	dd if=/dev/zero of=Pac-Man.trd bs=1 seek=16 count=32 conv=notrunc status=none

Pac-Man.tzx.zip:
	wget http://www.worldofspectrum.org/pub/sinclair/games/p/Pac-Man.tzx.zip

Pac-Man.tzx: Pac-Man.tzx.zip
	unzip -u Pac-Man.tzx.zip && touch Pac-Man.tzx

Pac-Man.tap: Pac-Man.tzx
	tzx2tap Pac-Man.tzx

headless.000: Pac-Man.tap
	tapto0 -f Pac-Man.tap

headless.bin: headless.000
	0tobin headless.000

screen.scr: headless.bin
	head -c 6912 headless.bin > screen.scr

screen.tap: screen.scr
	bin2tap -o screen.tap -a 16384 screen.scr

screen.000: screen.scr
	rm -f screen.000
	binto0 screen.scr 3 16384

screen.$$C: screen.000
	0tohob screen.000

screen.trd: screen.$$C
	createtrd screen.trd
	hobeta2trd screen.\$$C screen.trd

data.bin: headless.bin
	tail -c +6913 headless.bin > data.bin

data.000: data.bin
	rm -f data.000
	binto0 data.bin 3 23296

data.$$C: data.000
	0tohob data.000

loader.bin: src/loader.asm
	pasmo --bin src/loader.asm loader.bin

boot.bas: src/boot.bas loader.bin
	# Replace the __LOADER__ placeholder with the machine codes with bytes represented as {XX}
	sed "s/__LOADER__/$(shell hexdump -e '1/1 "{%02x}"' loader.bin)/" src/boot.bas > boot.bas

boot.tap: boot.bas
	bas2tap -sboot -a10 boot.bas boot.tap

boot.000: boot.tap
	tapto0 -f boot.tap

boot.$$B: boot.000
	0tohob boot.000

clean:
	rm -f \
		*.000 \
		*.\$$B \
		*.\$$C \
		*.bas \
		*.bin \
		*.scr \
		*.tap \
		*.trd \
		*.tzx \
		*.zip
