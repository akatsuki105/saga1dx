SECTION FRAGMENT "RAMCodeLoader", ROMX, BANK[8]
LoadBattleRAMCode::
  ld a, BANK(wBattleCode)
  ld bc, BattleCodeEnd - BattleCode
  ld de, wBattleCode
  ld hl, BattleCode
  call CopyFarCodeToWRAM
  ret

SECTION "RAMCopiedCode_Battle", ROMX, BANK[8]
BattleCode:
  LOAD "RAMCode_Battle", WRAMX[$D000], BANK[WRAM_BATTLE_BANK]
wBattleCode:

wSetEnemyAttr::
  push af
  set_rombank 8
  pop af
  call SetEnemyAttr ; SetEnemyAttr はWRAM1のデータを参照するため、WRAM4で実行できない
  push af
  set_rombank 7
  pop af
  ret

; parameters:
;   a = tile, hl = dst, bc = count
wClearScreen::
  push hl
  push bc
  push af
  set_vrambank 1
.loop
    wait_blank
    xor a
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop
  reset_vrambank
  pop af
  pop bc
  pop hl
  ret

; parameters:
;  de = dst, hl = src, b = width, c = height
wCopyEnemyBufferToVRAM::
  push_all
  set_vrambank 1
.loopY
    push bc
.loopX
      wait_blank
      ld a, [hli]
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
  reset_vrambank
  pop_all
  ret

; parameters:
;  de = dst, hl = src
;  b = width, c = height
wCopyTextboxBufferToVRAM::
  push af
  push bc
  push de
  set_vrambank 1
.loopY
    push bc
.loopX
      wait_blank
      ld a, 7
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
  reset_vrambank
  jp PopAndReturn + $1 ; de, bc, af

; parameters:
;  de = dst, hl = src, bc = bytesize
wCopyTextboxBGToWindow::
  push af
  push bc
  push de
  set_vrambank 1
  push bc
.loop
    wait_blank
    ld a, 7
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .loop
  pop bc
  reset_vrambank
  jp PopAndReturn + 1 ; de, bc, af

  ENDL
BattleCodeEnd:
  PRINTLN STRFMT("BattleRAMCode size: %d bytes", @ - BattleCode)
