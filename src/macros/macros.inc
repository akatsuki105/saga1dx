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

; jr命令に変えられる場合は警告を出す jp命令
MACRO? jmp
  jp \#
  if DEF(DEBUG)
    assert warn, (\<_NARG>) - @ > 127 || (\<_NARG>) - @ < -129, "jp can be jr"
  endc
ENDM

; LCDをオフにする (VBlank期間中にやらないとゲームボーイが壊れると言われている)
MACRO lcd_off
  push af
.wait_loop\@
    ldh a, [rLY]
    cp 145
    jr nz, .wait_loop\@
  xor a
  ldh [rLCDC], a
  pop af
ENDM

MACRO lcd_on
  push af
  ldh a, [rLCDC]
  set B_LCDC_ENABLE, a
  ldh [rLCDC], a
  pop af
ENDM
