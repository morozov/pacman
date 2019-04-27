Pac-Man.trd: boot.$$B
	createtrd Pac-Man.trd
	hobeta2trd boot.\$$B Pac-Man.trd
	hobeta2trd screenz.\$$C Pac-Man.trd
	hobeta2trd data.\$$C Pac-Man.trd

loader.bin: loader.asm
	pasmo --bin loader.asm loader.bin

boot.stub.bas: boot.bas.tpl loader.bin
	sed "s/__LOADER__/$(shell head -c $(shell stat --printf="%s" loader.bin) /dev/zero | tr '\0' -)/" boot.bas.tpl > boot.stub.bas

boot.stub.tap: boot.stub.bas
	bas2tap -sboot.stub boot.stub.bas boot.stub.tap

boot_stu.000: boot.stub.tap
	tapto0 -f boot.stub.tap

boot_stu.bas: boot_stu.000
	0tobin boot_stu.000

boot.bin: boot_stu.bas loader.bin
	cp boot_stu.bas boot.bin
	breplace 5 loader.bin boot.bin

boot.000: boot.bin
	binto0 boot.bin 0 10

boot.$$B: boot.000
	0tohob boot.000

clean:
	rm -f loader.bin boot.bas boot.\$$B boot.stub.bas boot.000 boot.bin boot_stu.000 boot_stu.bas boot.stub.tap Pac-Man.trd
