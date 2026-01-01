; Call WRAM banked function
MACRO farcall ; bank, address
  call FarCall
  db BANK(\1)
  dw \1
ENDM


