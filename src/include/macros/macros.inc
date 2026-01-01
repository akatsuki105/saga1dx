INCLUDE "macros/bank.inc"
INCLUDE "macros/farcall.inc"

MACRO push_all
  push af
  push bc
  push de
  push hl
ENDM

MACRO pop_all
  pop hl
  pop de
  pop bc
  pop af
ENDM

; VRAMとOAM にアクセスできるようになる V-Blank または H-Blank まで待つ
MACRO wait_blank
.wait_loop\@
  ldh a, [rSTAT]
  bit 1, a
  jr nz, .wait_loop\@
ENDM
