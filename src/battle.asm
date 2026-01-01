SECTION "CopyTextboxBufferToVRAM_Hook", ROMX[$63E7], BANK[6]
  call CopyTextboxBufferToVRAM ; このコードはテキストボックスのバッファをVRAMにコピーします。全てテキストボックスと仮定できるので、ここでカラー化します。

SECTION "SetAllWhite_Hook7382", ROMX[$7382], BANK[7]
  call SetAllWhite

SECTION "SetEnemyAttr_Hook", ROMX[$73DF], BANK[7]
  call SetEnemyAttrTrampoline
rept 13
  nop
endr

SECTION "ClearScreen_Hook", ROMX[$73FA], BANK[7]
  call ClearScreen

SECTION "CopyEnemyBufferToVRAM_Hook", ROMX[$7406], BANK[7]
  call CopyEnemyBufferToVRAM

SECTION "ShowScreen_Hook", ROMX[$7437], BANK[7]
  call ShowScreen

SECTION "CopyTextboxBGToWindow_Hook", ROMX[$7A76], BANK[7]
  call CopyTextboxBGToWindow

SECTION "Free_BattleCode", ROM0
SetEnemyAttrTrampoline:
  farcall wSetEnemyAttr
  ret
SetAllWhite:
  call LoadWhiteBGPalette
  ld hl, $D819 ; JP/US共通
  ret

ClearScreen:
  farcall wClearScreen
  call vramset16
  ret

CopyEnemyBufferToVRAM:
  farcall wCopyEnemyBufferToVRAM
  call FUN_0186
  ret

ShowScreen:
  push hl
  ld hl, wPaletteBattle
  call LoadBGPalette
  pop hl
  call $01D7
  ret

CopyTextboxBufferToVRAM:
  farcall wCopyTextboxBufferToVRAM
  call FUN_0186
  ret

CopyTextboxBGToWindow:
  farcall wCopyTextboxBGToWindow
  call vramcpy16
  ret
  PRINTLN STRFMT("Free_BattleCode size: %d bytes", @ - SetEnemyAttrTrampoline)

SECTION "SetEnemyAttr", ROMX, BANK[8]
SetEnemyAttr::
  ; parameters:
  ;   a = first enemy tile ID, bc = width/height, e = enemies remaining, hl = dst
  push_all
  reset_wrambank
  ; Get enemy count - 1 into DE, because the game renders enemies in reverse order
  ld a, e
  dec a
  ld e, a
  xor a
  ld d, a
  ld hl, wBattleEnemyID ; Get enemy ID into A
  sla e
  add hl, de
  ld a, [hl]
  ; Get enemy palette into A
  ld hl, EnemyColors
  ld e, a ; Enemy ID
  ld d, 0
  add hl, de
  ld a, [hl]
  pop hl
  pop de
  push de
  push hl
  push af
  set_wrambank WRAM_BATTLE_BANK
  pop af
  ld d, c
.attrLoopY
    ld c, d
.attrLoopX
      ld [hli], a
      dec c
      jr nz, .attrLoopX
    push af
    ld a, $14
    sub d
    add l
    ld l, a
    pop af
    dec b
    jr nz, .attrLoopY
  reset_wrambank
  pop_all
  ; original code (07:73DF .. 07:73EE)
  ld d, c
.idLoopY
    ld c, d
.idLoopX
      ld [hli], a
      inc a
      dec c
      jr nz, .idLoopX
    push af
    ld a, $14
    sub d
    rst AddHL
    pop af
    dec b
    jr nz, .idLoopY
  set_wrambank WRAM_BATTLE_BANK
  ret
