SECTION FRAGMENT "RAMCodeLoader", ROMX, BANK[8]
LoadMenuRAMCode::
  ld a, BANK(wMenuCode)
  ld bc, MenuCodeEnd - MenuCode
  ld de, wMenuCode
  ld hl, MenuCode
  call CopyFarCodeToWRAM
  ret

SECTION "RAMCopiedCode_Menu", ROMX, BANK[8]
MenuCode:
  LOAD "RAMCode_Menu", WRAMX[$D000], BANK[WRAM_MENU_BANK]
wMenuCode:

wClearMenuBackground::
  set_vrambank 1
  ld hl, $9C00
  ld c, $12
  ld de, $000C
.label2D03v
    ld b, $14
.label2D05v
      wait_blank
      ld a, $07
      ld [hli], a
      dec b
      jr nz, .label2D05v
    add hl, de
    dec c
    jr nz, .label2D03v
  reset_vrambank
  ld hl, $9C00
  ld c, $12
  ld de, $000C
.label2D03
    ld b, $14
.label2D05
      wait_blank
      ld a, $7F
      ld [hli], a
      dec b
      jr nz, .label2D05
    add hl, de
    dec c
    jr nz, .label2D03
  ret

wClearTextbox::
  push_all
  ld hl, $9C21
  ld b, $06
  ld de, $0E
.clearTextboxloopY
    ld c, $12
.clearTextboxloopX
      wait_blank
      ld a, $7F
      ld [hli], a
      dec c
      jr nz, .clearTextboxloopX
    add hl, de
    dec b
    jr nz, .clearTextboxloopY
  jp PopAndReturn

wMenuLoadTiles::
  ; de = dst, b = width, c = height
  ld hl, $C600
  push af
  set_vrambank 1
  push bc
  push de
.loopY
    push bc
.loopX
      wait_blank
      ld a, $7
      ld [de], a
      inc de
      dec b
      jr nz, .loopX
    pop bc
    ld a, $20
    sub b
    add e
    ld e, a
    ld a, d
    adc 0
    ld d, a
    dec c
    jr nz, .loopY
  pop de
  pop bc
  reset_vrambank
  pop af
  ret

  ENDL
MenuCodeEnd:
