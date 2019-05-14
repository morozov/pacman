     ORG     $8000
     LD      HL, data-1
     LD      DE, $5AFF
     JP      dzx7
     include lib/dzx7b_medium.asm
     incbin  screen.zx7b
data:

