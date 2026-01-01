; Metatile: 8x8px のタイル を 2x2 でまとめた 16x16px のタイル単位のデータ構造

SECTION "WriteRowMetatileToRAM_Hook", ROM0[$137B]
  di
  push af
  set_wrambank WRAM_METATILE_BANK
  pop af
  call wWriteRowMetatileToRAM
  reset_wrambank
  ei
  nop

SECTION "WriteHalfMetatileToRAM_Hook13A3", ROM0[$13A3]
  call WriteHalfMetatileToRAM
SECTION "WriteHalfMetatileToRAM_Hook13A7", ROM0[$13A7]
  call WriteHalfMetatileToRAM
SECTION "WriteMetatileToVRAM_Hook", ROM0[$1517]
  call WriteMetatileToVRAM

SECTION "CopyMetatileColumnToVRAM_Hook", ROM0[$142D]
  di
  push af
  set_wrambank WRAM_METATILE_BANK
  pop af
  call CopyMetatileColumnToVRAM_Far
  reset_wrambank
  reti

SECTION "CopyMetatileRowToVRAM_Hook", ROM0[$1441]
  di
  push af
  set_wrambank WRAM_METATILE_BANK
  pop af
  call CopyMetatileRowToVRAM_Far
  reset_wrambank
  reti

SECTION "StoreMetatileAttribute_Hook", ROM0[$3F94]
  call StoreMetatileAttribute

SECTION "Free_MapCode", ROM0
StoreMetatileAttribute:
  farcall wStoreMetatileAttribute
  ret
WriteHalfMetatileToRAM:
  farcall wWriteHalfMetatileToRAM
  ret
  PRINTLN STRFMT("Free_MapCode size: %d bytes", @ - StoreMetatileAttribute)

; 空きスペースの関係で MapCode と離れた場所に配置
SECTION "Free_MapCode2", ROM0
WriteMetatileToVRAM:
  push af
  set_wrambank WRAM_PALETTE_BANK
  xor a
  ld [wRequestedPalette], a
  dec a
  ld [wLastFadeValue], a
  reset_wrambank
  pop af
  farcall wWriteMetatileToVRAM
  ret
  PRINTLN STRFMT("Free_MapCode2 size: %d bytes", @ - WriteMetatileToVRAM)

