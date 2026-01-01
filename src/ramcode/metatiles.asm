SECTION FRAGMENT "RAMCodeLoader", ROMX, BANK[8]
LoadMetatileRAMCode::
  ld a, BANK(wMetatileCode)
  ld bc, MetatileCodeEnd - MetatileCode
  ld de, wMetatileCode
  ld hl, MetatileCode
  call CopyFarCodeToWRAM
  ret

SECTION "RAMCopiedCode_Metatile", ROMX, BANK[8]
MetatileCode:
  LOAD "RAMCode_Metatile", WRAMX[$D800], BANK[WRAM_METATILE_BANK]
wMetatileCode:

wStoreMetatileAttribute::
  ; c = tileset to load
  push hl
  push de
  push bc
  push af
  set_rombank 8
  ld b, c
  xor a
  ld c, a
  rr b
  rr c
  ld hl, MetatileAttr
  add hl, bc
  ld de, wMetatileAttr
  ld b, $80
.loop
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .loop
  set_rombank 2
  pop af
  pop bc
  pop de
  pop hl
  sla c
  ld b, $00
  ret

wWriteRowMetatileToRAM::
  ; a = tileID, hl = dst
  call wWriteHalfMetatileToRAM
  inc a
  ld c, a
  push hl
  ld a, l
  add $14
  ld l, a
  ld a, c
  call wWriteHalfMetatileToRAM
  pop hl
  ret

wWriteHalfMetatileToRAM::
  ; a = tileID, hl = dst
  push af
  push de
  push hl
  ld de, wMetatileAttr
  and $7F
  ld e, a
  set_vrambank 1
  ld h, HIGH(wMetatileBuffer) ; ld h, 0xD5
  ld a, [de]
  inc de
  ld [hli], a
  ld a, [de]
  inc de
  ld [hli], a
  reset_vrambank
  pop hl
  pop de
  pop af
  ; Original code
  ld [hli], a
  inc a
  ld [hli], a
  ret

wWriteMetatileToVRAM::
  ; a = tileID, hl = dst
  push af
  push de
  push hl
  ld de, wMetatileAttr
  and $7F
  ld e, a
  set_vrambank 1
    wait_blank
    ld a, [de]
    inc de
    ld [hli], a
    ld a, [de]
    inc de
    ld [hld], a
    set 5, l
    wait_blank
    ld a, [de]
    inc de
    ld [hli], a
    ld a, [de]
    inc de
    ld [hl], a
  reset_vrambank
  pop hl
  pop de
  wait_blank
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
  pop  hl
  push hl
  reset_vrambank
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
  reset_vrambank
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

  ENDL
MetatileCodeEnd:
