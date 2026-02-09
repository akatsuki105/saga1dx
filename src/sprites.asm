; Hooks

; US: $03F1
SECTION "Hook_MenuSpriteAttribute", ROM0[$03D7]
  call MenuSpriteAttribute

; US: $05D3
SECTION "StoreSpriteIDs8_Hook05D3", ROM0[$05B9]
  call StoreSpriteIDs8

; US: $1E1B
SECTION "NPCSpriteAttribute_Hook1E1B", ROM0[$1E1F]
  farcall NPCSpriteAttribute

; US: $1FE9
SECTION "PlayerSpriteAttribute_Hook1FE9", ROM0[$1FED]
  call PlayerSpriteAttribute

; US: $2002
SECTION "PlayerSpriteAttribute_Hook2002", ROM0[$2006]
  call PlayerSpriteAttribute

; US: $251A
SECTION "StoreSpriteIDs_Hook251A", ROM0[$251E]
  call StoreSpriteIDs

; US: $256A
SECTION "StoreSpriteIDs_Hook256A", ROM0[$256E]
  call StoreSpriteIDs

; このパッチでは vramcpy の時に、vramcpy の引数から　スプライトの属性 を計算して WRAM に保存しておき、 OAM の更新時にフックして、その保存した属性を反映している
; つまり スプライトの着色はスプライトのタイルデータが vramcpy されている前提で動作する
; 大抵の部分はまず vramcpy してから OAM 更新なので問題ないが、いくつか OAM を更新してから vramcpy する部分があるため、その部分では正しく色が反映されないため、特殊処理をする
SECTION "Hook_LoadMenuSprite_NameInput", ROMX[$7CA3], BANK[3]
  farcall LoadMenuSpriteDX_NameInput
SECTION "Hook_LoadMenuSprite_Battle", ROMX[$6325], BANK[6]
  nop
  farcall LoadMenuSpriteDX_Battle

; JP/US: Same address
SECTION "EffectSpriteAttribute_Hook7166", ROMX[$7166], BANK[7]
  call EffectSpriteAttribute

SECTION FRAGMENT "Free_247", ROM0

StoreSpriteIDs8:
  farcall _StoreSpriteIDs8
  call vramcpy8_far
  ret

StoreSpriteIDs:
  farcall _StoreSpriteIDs
  call vramcpy16
  ret

MenuSpriteAttribute:
  farcall _MenuSpriteAttribute
  ret

PlayerSpriteAttribute:
  farcall _PlayerSpriteAttribute
  ret

SECTION FRAGMENT "bank8", ROMX
LoadSpriteAttrs::
  set_wrambank WRAM_SPRITE_BANK
  ld bc, SpriteAttrEnd - SpriteAttr
  ld de, wSpriteAttr
  ld hl, SpriteAttr
  call memcpy16
  ; Colorize meat, which is at a fixed location in VRAM
  ld a, 1
  ld hl, wSpriteIDs+$FA
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hl], a
  set_wrambank 1
  ret

LoadMenuSpriteDX_Battle:
  ; original code
  add 5
  ld l, a
  ld a, [hl]
  call LoadMenuSpriteDX
  ret

LoadMenuSpriteDX_NameInput:
  ld de, $8000 ; original code
  call LoadMenuSpriteDX
  ret

LoadMenuSpriteDX:
  call _LoadMenuSprite ; ここで StoreSpriteIDs8 がセットされる
  push af
  push hl
  xor a
  ld hl, wOAM1 + $03
  call _SetMetaspriteAttribute
  ld hl, wOAM1 + $13
  call _SetMetaspriteAttribute
  ld hl, wOAM1 + $23
  call _SetMetaspriteAttribute
  ld hl, wOAM1 + $33
  call _SetMetaspriteAttribute
  pop hl
  pop af
  ret

; parameters:
;  hl = $C0x3 (wOAM1)
_MenuSpriteAttribute:
  push de
  ; hl = shadow OAM location
  dec hl
  ld a, [hli] ; a = tileID
  ;load $D000 + A into DE
  ld d, $D0
  ld e, a
  set_wrambank WRAM_SPRITE_BANK
  ; load metatile attribute from HL
  ld a, [de]
  push af
  set_wrambank 1
  pop af
  ;original code
  ld [hli], a
  inc hl
  inc hl
  inc hl
  pop de
  ret

_PlayerSpriteAttribute::
  ; hl = shadow OAM location
  push af
  dec hl
  ld a, [hli]
  ;load $D000 + A into HL
  push hl
  ld h, $D0
  ld l, a
  set_wrambank WRAM_SPRITE_BANK
  ld a, [hl]
  push af
  set_wrambank 1
  ;load metatile attribute from HL
  ld a, c
  and $E0
  pop hl ; h = attr
  or h
  ld c, a
  pop hl
  pop af
  ;original code
  and $D0
  or c
  ret

_StoreSpriteIDs8::
  ; a = bank, de = dst, hl = src, b = (u8)bytesize
  push bc
  push af
  xor a
  ld c, b
  ld b, a
  pop af
  call _StoreSpriteIDs
  pop bc
  ret

; キャラクタのVRAMレイアウトが固定されていることを利用してvramcpyの引数からごにょごにょ
; parameters:
; a = bank, de = dst in VRAM, hl = src, bc = (u16)bytesize
_StoreSpriteIDs::
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
  set_wrambank WRAM_SPRITE_BANK
.loop
    ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, .loop
  set_wrambank 1
  pop af
  pop bc
  pop de
  pop hl
  ret

; parameters:
;   c = tileID, hl = WRAM OAM location
NPCSpriteAttribute::
  push af
  set_wrambank WRAM_SPRITE_BANK
  dec hl
  ld a, [hli] ; a = tileID
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
  set_wrambank 1
  pop af
  ; original code ($1E1F..1E24)
  and $D0
  or b
  ld [hli], a
  inc l
  inc l
  ret

SECTION "EffectSpriteAttribute", ROM0[$0469]
; parameters:
;  hl = wOAMx.2 (e.g. $CCx2), a = tile id, c = OAM.3
EffectSpriteAttribute::
  push bc
  ld [hli], a
  ;load $D400 + A into HL
  push hl
  ld h, $D4
  ld l, a
  set_wrambank WRAM_SPRITE_BANK
  ;load metatile attribute from HL into C, combining it with the original attributes
  ld a, [hl]
  or c ; c = vanilla attr | dx attr
  ld c, a
  set_wrambank 1
  pop hl
  ;Original code
  ld [hl], c
  inc hl
  pop bc
  ret
