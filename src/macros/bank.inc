MACRO set_rombank ; banknum
  ld a, \1 ; 2cycles, 2byte
  ld [rROM2B], a
ENDM

MACRO set_wrambank ; banknum
  if \1 == 0
    xor a
  else
    ld a, \1
  endc
  ldh [rWBK], a
ENDM

MACRO set_vrambank ; banknum
  if \1 == 0
    xor a
  else
    ld a, \1
  endc
  ldh [rVBK], a
ENDM
