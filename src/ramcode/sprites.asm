SECTION FRAGMENT "RAMCodeLoader", ROMX, BANK[8]
LoadSpriteRAMCode::
  ld a, BANK(wSpriteCode)
  ld bc, SpriteCodeEnd - SpriteCode
  ld de, wSpriteCode
  ld hl, SpriteCode
  call CopyFarCodeToWRAM
  ret

SECTION "RAMCopiedCode_Sprite", ROMX, BANK[8]
SpriteCode:
  LOAD "RAMCode_Sprite", WRAMX[$DC00], BANK[WRAM_SPRITE_BANK]
wSpriteCode:

wStoreSpriteIDs8::
  ; a = bank, de = dst, hl = src, b = (u8)bytesize
  push bc
  push af
  xor a
  ld c, b
  ld b, a
  pop af
  call wStoreSpriteIDs
  pop bc
  ret

wStoreSpriteIDs::
  ; a = bank, de = dst, hl = src, bc = (u16)bytesize
	push hl
	push de
	push bc
	push af ; この順番で保存すること
  ; HL = ((HL >> 4) | (BANK << 10)), the index of the 16-byte block in the $4000~$7FFF range.
    ld a, h
    and $3F
    ld h, a
rept 4
    srl h
    rr l
endr
    pop af
    push af
  ; Aがバンクだと思っていたが、どうやらすべてのスプライトがバンク1からコードを読み込んでいるようだ。だから今のところバンクは無視していい。
  xor a
  sla a
  sla a
  add $D0
  add h
  ld h, a
  push hl
  ; Get number of tiles into B
    ld h, b
    ld l, c
    ; hl *= 16
rept 4
    add hl, hl
endr
    ld b, h
  ; Calculate the destination address in WRAM
  ; Divide the tile vram address by $10 (size of a tile) and multiply by two.  Easiest way is to shift left five times and discard the low value.
  ; hl = $D000 | ((DE & $07FF) * $20)
    ld h, d
    ld l, e
    ; hl *= 16
rept 4
    add hl, hl
endr
    ld l, h
    ld h, $D0
  ; Pop the old HL (bank<<10|addr>>4) into DE
  pop de
.loop
    ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, .loop
  pop af
  pop bc
  pop de
  pop hl
  ret

wMenuSpriteAttribute::
  ; hl = shadow OAM location
  dec hl
  ld a, [hli]
  ;load $D000 + A into DE
  push de
  ld d, $D0
  ld e, a
  ;load metatile attribute from HL
  ld a, [de]
  pop de
  ;original code
  ld [hli], a
  inc hl
  inc hl
  inc hl
  ret

wPlayerSpriteAttribute::
  ; hl = shadow OAM location
  push af
  dec hl
  ld a, [hli]
  ;load $D000 + A into HL
  push hl
  ld h, $D0
  ld l, a
  ;load metatile attribute from HL
  ld a, c
  and $E0
  or [hl]
  ld c, a
  pop hl
  pop af
  ;original code
  and $D0
  or c
  ret

wNPCSpriteAttribute::
  ; c = tileID, hl = shadow OAM location
  push af
  dec hl
  ld a, [hli]
  ; load $D000 + A into HL
  push hl
  ld h, $D0
  ld l, a
  ; load metatile attribute from HL
  ld a, b
  and $E0
  or [hl]
  ld b, a
  pop hl
  pop af
  ; original code
  and $D0
  or b
  ret

wEffectSpriteAttribute::
  push bc
  push af
  ld [hli], a
  ;load $D400 + A into HL
  push hl
    ld h, $D4
    ld l, a
    ;load metatile attribute from HL into C, combining it with the original attributes
    ld a, [hl]
    or c
    ld c, a
  pop hl
  pop af
  ;Original code
  ld [hl], c
  inc hl
  pop bc
  ret

  ENDL
SpriteCodeEnd:
