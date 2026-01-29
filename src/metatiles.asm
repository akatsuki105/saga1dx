; Metatile: 8x8px のタイル を 2x2 でまとめた 16x16px のタイル単位のデータ構造

SECTION "WriteRowMetatileToRAM_Hook", ROM0[$137B]
  farcall WriteRowMetatileToRAM
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop

SECTION "WriteHalfMetatileToRAM_Hook13A3", ROM0[$13A3]
  call WriteHalfMetatileToRAM
SECTION "WriteHalfMetatileToRAM_Hook13A7", ROM0[$13A7]
  call WriteHalfMetatileToRAM
SECTION "WriteMetatileToVRAM_Hook", ROM0[$1517]
  call WriteMetatileToVRAM

SECTION "CopyMetatileColumnToVRAM_Hook", ROM0[$142D]
  farcall CopyMetatileColumnToVRAM_Far
  ret

SECTION "CopyMetatileRowToVRAM_Hook", ROM0[$1441]
  farcall CopyMetatileRowToVRAM_Far
  ret

SECTION "StoreMetatileAttribute_Hook", ROM0[$3F94]
  call StoreMetatileAttribute
  nop

SECTION "Free_MapCode", ROM0
StoreMetatileAttribute:
  farcall _StoreMetatileAttribute
  ret

WriteHalfMetatileToRAM:
  farcall _WriteHalfMetatileToRAM
  ret

; 空きスペースの関係で MapCode と離れた場所に配置
SECTION "Free_MapCode2", ROM0
WriteMetatileToVRAM:
  push af
  set_wrambank WRAM_PALETTE_BANK
  xor a
  ld [wRequestedPalette], a
  dec a
  ld [wLastFadeValue], a
  set_wrambank 0
  pop af
  farcall _WriteMetatileToVRAM
  ret

SECTION FRAGMENT "bank8", ROMX
; parameters:
; a = tileID, hl = dst in VRAM, de = src in WRAM1
_WriteMetatileToVRAM::
  push af
  push de
  push hl
  ld de, wMetatileAttr
  and $7F
  ld e, a
  set_wrambank WRAM_METATILE_BANK
  set_vrambank 1
    ld a, [de]
    inc de
    ld [hli], a
    ld a, [de]
    inc de
    ld [hld], a
    set 5, l
    ld a, [de]
    inc de
    ld [hli], a
    ld a, [de]
    inc de
    ld [hl], a
  set_vrambank 0
  set_wrambank 1
  pop hl
  pop de
  pop af
  ; Original code
  ld [hli], a
  inc a
  ld [hld], a
  ret

CopyMetatileRowToVRAM_Far::
  push hl
  set_vrambank 1
  ld de, wMetatileBuffer
  ld b, $0B
  set_wrambank WRAM_METATILE_BANK
.label1447v
    ld a, [de]
    ld [hli], a
    inc e
    ld a, [de]
    ld [hli], a
    res  5,l
    inc  e
    dec  b
    jr   nz, .label1447v
  pop  hl
  push hl
  set 5,l
  ld  b, $0B
.label1457v
    ld a, [de]
    ld [hli], a
    inc e
    ld a, [de]
    ld [hl], a
    res  5,l
    inc  l
    set  5,l
    inc  e
    dec  b
    jr   nz, .label1457v
  set_wrambank 1
  pop  hl
  push hl
  set_vrambank 0
  ld de, $C500
  ld b,  $0B
.label1447
    ld a, [de]
    ld [hli], a
    inc e
    ld a, [de]
    ld [hli], a
    res  5,l
    inc  e
    dec  b
    jr   nz, .label1447
  pop  hl
  set  5,l
  ld   b, $0B
.label1457
    ld a, [de]
    ld [hli], a
    inc e
    ld a, [de]
    ld [hl], a
    res  5,l
    inc  l
    set  5,l
    inc  e
    dec  b
    jr   nz, .label1457
  ret

CopyMetatileColumnToVRAM_Far::
  push hl
  set_vrambank 1
  ld de, wMetatileBuffer
  ld b,  $12
  set_wrambank WRAM_METATILE_BANK
.label1432v
    ld a, [de]
    ld [hli], a
    inc e
    ld a, [de]
    ld [hl], a
    inc e
    ld  a, $1F
    add l
    ld l, a
    adc h
    sub l
    ld  h, a
    res 2, h
    dec b
    jr  nz, .label1432v
  set_vrambank 0
  set_wrambank 1
  pop hl
  ld de, $C500
  ld b,  $12
.label1432
    ld a, [de]
    ld [hli], a
    inc e
    ld a, [de]
    ld [hl], a
    inc e
    ld  a, $1F
    add l
    ld l, a
    adc h
    sub l
    ld  h, a
    res 2, h
    dec b
    jr  nz, .label1432
  ret

WriteRowMetatileToRAM::
  ; a = tileID, hl = dst
  call _WriteHalfMetatileToRAM
  inc a
  ld c, a
  push hl
  ld a, l
  add $14
  ld l, a
  ld a, c
  call _WriteHalfMetatileToRAM
  pop hl
  ret

; parameters:
; a = tileID, hl = dst
_WriteHalfMetatileToRAM::
  push af
  push de
  push hl
  ld de, wMetatileAttr
  and $7F
  ld e, a
  set_wrambank WRAM_METATILE_BANK
  set_vrambank 1
  ld h, HIGH(wMetatileBuffer) ; ld h, 0xD5
  ld a, [de]
  inc de
  ld [hli], a
  ld a, [de]
  inc de
  ld [hli], a
  set_vrambank 0
  set_wrambank 1
  pop hl
  pop de
  pop af
  ; Original code
  ld [hli], a
  inc a
  ld [hli], a
  ret

; c = tileset to load
_StoreMetatileAttribute::
  push de
  push bc
  push af
  ld b, c
  xor a
  ld c, a
  rr b
  rr c
  ld hl, MetatileAttr
  add hl, bc
  ld de, wMetatileAttr
  ld b, $80/4
  set_wrambank WRAM_METATILE_BANK
.loop
rept 4
    ld a, [hli]
    ld [de], a
    inc de
endr
    dec b
    jr nz, .loop
  set_wrambank 1
  pop af
  pop bc
  pop de
  ; $3F94..3F96
  sla c
  ld b, $00
  ret
