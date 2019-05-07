i 16384 Loading screen
i 23296
c $5D00 Decoded loader
i $5D25
c $5D26 Bootstrap
c $5D29 Decoder of the loader
  $5D29 Load the address of ERR_NR into DE
  $5D2D Length of the encoded loader
  $5D2F Exchange DE and HL so that now HL contains $5C3A
  $5D33 Increment HL by DE ($19) so now it contains $5C53 which is PROG
  $5D34,3 Load the address of PROG into DE
  $5D3B Load A with the XOR key from the offset relative to PROG
  $5D3E Offset of the encoded loader relative to PROG
  $5D42 Push the address of the loader on stack
  $5D43 Un-XOR the loader
  $5D48,2 Jump to the decoded loader
b $5D4A XOR key
i $5D4B ignore
