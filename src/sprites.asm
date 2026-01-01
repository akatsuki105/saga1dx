; Hooks

; US: $03F1
SECTION "Hook_MenuSpriteAttribute", ROM0[$03D7]
  call MenuSpriteAttribute

; US: $05D3
SECTION "StoreSpriteIDs8_Hook05D3", ROM0[$05B9]
  call StoreSpriteIDs8

; US: $1E1B
SECTION "NPCSpriteAttribute_Hook1E1B", ROM0[$1E1F]
  call NPCSpriteAttribute

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

; JP/US: Same address
SECTION "EffectSpriteAttribute_Hook7166", ROMX[$7166], BANK[7]
  call EffectSpriteAttribute

SECTION "Free_SpriteCode", ROM0

StoreSpriteIDs8:
  farcall wStoreSpriteIDs8
  call vramcpy8_far
  reti

StoreSpriteIDs:
  farcall wStoreSpriteIDs
  call vramcpy16
  reti

MenuSpriteAttribute:
  farcall wMenuSpriteAttribute
  ret

NPCSpriteAttribute:
  farcall wNPCSpriteAttribute
  ret

PlayerSpriteAttribute:
  farcall wPlayerSpriteAttribute
  ret

EffectSpriteAttribute:
  farcall wEffectSpriteAttribute
  ret
  PRINTLN STRFMT("Free_SpriteCode size: %d bytes", @ - MenuSpriteAttribute)

SECTION FRAGMENT "RAMDataLoader", ROMX, BANK[8]
LoadSpriteAttrs::
  ld a, BANK(wSpriteAttr)
  ld bc, SpriteAttrEnd - SpriteAttr
  ld de, wSpriteAttr
  ld hl, SpriteAttr
  call CopyFarCodeToWRAM
  ; Colorize meat, which is at a fixed location in VRAM
  set_wrambank WRAM_SPRITE_BANK
  ld a, 1
  ld hl, wSpriteIDs+$FA
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hl], a
  reset_wrambank
  ret
