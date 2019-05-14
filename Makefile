Pac-Man.scl: Pac-Man.trd
	trd2scl Pac-Man.trd Pac-Man.scl

# The compressed screen is created by Laser Compact v5.2
# and cannot be generated at the build time
# see https://spectrumcomputing.co.uk/?cat=96&id=21446
Pac-Man.trd: boot.$$B screen.$$C data.$$C
# Create a temporary file first in order to make sure the target file
# gets created only after the entire job has succeeded
	$(eval TMPFILE=$(shell tempfile))

	createtrd $(TMPFILE)
	hobeta2trd boot.\$$B $(TMPFILE)
	hobeta2trd screen.\$$C $(TMPFILE)
	hobeta2trd data.\$$C $(TMPFILE)

# Write the correct length to the first file (offset 13)
# The lenth is 1 (boot) + 9 (loading screen) + 37 (data) = 47
# Got to use the the octal notation since it's the only format of binary data POSIX printf understands
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html#tag_20_94_13
	printf '\057' | dd of=$(TMPFILE) bs=1 seek=13 conv=notrunc status=none

# Remove two other files (fill 2×16 bytes starting offset 16 with zeroes)
	dd if=/dev/zero of=$(TMPFILE) bs=1 seek=16 count=32 conv=notrunc status=none

# Rename the temporary file to target name
	mv $(TMPFILE) Pac-Man.trd

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

screen.zx7b: screen.scr
	zx7b screen.scr screen.zx7b

screen.tap: src/screen.asm screen.zx7b
	pasmo --tap --name screen src/screen.asm screen.tap

screen.000: screen.tap
	tapto0 -f screen.tap

screen.$$C: screen.000
	0tohob screen.000

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
