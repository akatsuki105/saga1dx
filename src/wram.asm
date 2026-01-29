SECTION "wFarCall2", WRAM0[$C0A0]
wFarCall2::
  ; ld a, ??
  db
.A::
  db
  ; jp ????
  db ; jp
.Dst::
  dw ; dst

SECTION "MetatileRAM", WRAMX[$D000], BANK[WRAM_METATILE_BANK]
wMetatileAttr::
  ds $500
wMetatileBuffer::
  ds $300

SECTION "InitialPal", WRAMX[$D000], BANK[WRAM_PALETTE_BANK]
wPalettes::
wPaletteBG::
  ds $40
wPaletteOBJ::
  ds $40
wPaletteBattle::
  ds $40
wPaletteTitle::
  ds $40
wPalettesEnd::

SECTION "PaletteLookup", WRAMX[$D300], BANK[WRAM_PALETTE_BANK]
wPaletteLookup::
  ds 256

SECTION "PaletteStates", WRAMX[$DFFD], BANK[WRAM_PALETTE_BANK]
wRequestedPalette::
  ds 1
wLastFadeValue::
  ds 1
wIsTitle::
  ds 1

SECTION "SpriteWRAM", WRAMX[$D000], BANK[WRAM_SPRITE_BANK]
wSpriteIDs::
  ds 512
wSpriteAttr::
  ds 576

