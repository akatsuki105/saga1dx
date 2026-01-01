MACRO set_rombank ; banknum
  if \1 == 0
    xor a ; 1cycle, 1byte
  else
    ld a, \1 ; 2cycles, 2byte
  endc
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

MACRO reset_wrambank
  set_wrambank 0
ENDM

MACRO set_vrambank ; banknum
  if \1 == 0
    xor a
  else
    ld a, \1
  endc
  ldh [rVBK], a
ENDM

MACRO reset_vrambank
  set_vrambank 0
ENDM
