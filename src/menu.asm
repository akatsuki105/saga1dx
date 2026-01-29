; US: $2A9C
SECTION "MenuLoadTiles_Hook", ROM0[$2AA0]
  call MenuLoadTiles

; US: $2CF2
SECTION "ClearMenuBackground_Hook", ROM0[$2CF6]
  farcall ClearMenuBackground
  ret ; オリジナルの処理全部やったのでreturn

; US: $35A1
SECTION "ClearTextbox_Hook", ROM0[$3599]
  ; farcall ClearTextbox

SECTION "MenuLoadTiles_Hook7AF7", ROMX[$7AF7], BANK[3]
  ld de, $9C00
  ld bc, $1412
  call MenuLoadTiles

; US: $144F
SECTION "Free_MenuCode", ROM0
MenuLoadTiles:
  farcall _MenuLoadTiles
  ret

SECTION FRAGMENT "bank8", ROMX
_MenuLoadTiles::
  ; de = dst, b = width, c = height
  ld hl, $C600
  push af
  set_vrambank 1
  push bc
  push de
  call VRAMEnable
.loopY
    push bc
.loopX
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
  call VRAMDisable
  pop de
  pop bc
  set_vrambank 0
  pop af
  ret

ClearMenuBackground:
  ld hl, $9C00
  ld c, $12
  ld de, $000C
  set_vrambank 1
  call VRAMEnable
.label2D03v
    ld b, $14/2
.label2D05v
      ld a, $07
rept 2
      ld [hli], a
endr
      dec b
      jr nz, .label2D05v
    add hl, de
    dec c
    jr nz, .label2D03v
  set_vrambank 0
  ld hl, $9C00
  ld c, $12
  ld de, $000C
.label2D03
    ld b, $14/2
.label2D05
      ld a, $7F
rept 2
      ld [hli], a
endr
      dec b
      jr nz, .label2D05
    add hl, de
    dec c
    jr nz, .label2D03
  call VRAMDisable
  ret


ClearTextbox::
  push_all
  ld hl, $9C21
  ld b, $06
  ld de, $0E
  call VRAMEnable
.clearTextboxloopY
    ld c, $12/2
.clearTextboxloopX
      ld a, $7F
      ld [hli], a
      ld [hli], a
      dec c
      jr nz, .clearTextboxloopX
    add hl, de
    dec b
    jr nz, .clearTextboxloopY
  call VRAMDisable
  pop_all
  call FUN_14E4
  ld [$C5CA], a
  ret

