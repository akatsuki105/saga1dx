SECTION "CopyTextboxBufferToVRAM_Hook", ROMX[$63E7], BANK[6]
  call CopyTextboxBufferToVRAM ; このコードはテキストボックスのバッファをVRAMにコピーします。全てテキストボックスと仮定できるので、ここでカラー化します。

SECTION "SetAllWhite_Hook7382", ROMX[$7382], BANK[7]
  call SetAllWhite

SECTION "Move_FUN_07_749a_Hook", ROMX[$73C9], BANK[7]
  farcall FUN_07_749a

SECTION "SetEnemyAttr_Hook", ROMX[$73DF], BANK[7]
  farcall SetEnemyAttr
rept 10
  nop
endr

SECTION "ClearScreen_Hook", ROMX[$73F7], BANK[7]
  farcall ClearScreen

SECTION "CopyEnemyBufferToVRAM_Hook", ROMX[$7403], BANK[7]
  farcall CopyEnemyBufferToVRAM

SECTION "ShowScreen_Hook", ROMX[$7437], BANK[7]
  call ShowScreen

SECTION "CopyTextboxBGToWindow_Hook", ROMX[$7A76], BANK[7]
  call CopyTextboxBGToWindow

SECTION FRAGMENT "bank8", ROMX
; parameters:
;   a = tile, hl = dst, bc = count
ClearScreen:
  ld hl, TILEMAP0
  push hl
  push bc
  push af
  call VRAMEnable
  set_vrambank 1
.loop
    xor a
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop
  set_vrambank 0
  pop af
  pop bc
  pop hl
  call memset16
  call VRAMDisable
  ret

; parameters:
;  de = dst, hl = src, b = width, c = height
_CopyTextboxBufferToVRAM::
  push af
  push bc
  push de
  set_vrambank 1
  call VRAMEnable
.loopY
    push bc
.loopX
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
  set_vrambank 0
  call VRAMDisable
  pop de
  pop bc
  pop af
  ret

; TODO: WRAMバンク切り替え中に、VRAMEnable が使ってもいいか確認する
; parameters:
;  de = dst, hl = src, b = width, c = height
CopyEnemyBufferToVRAM::
  ld bc, $1408
  push_all
  set_vrambank 1
  di
  set_wrambank WRAM_BATTLE_BANK
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
  set_wrambank 1
  ei
  set_vrambank 0
  pop_all
  call FUN_0186
  ret

; 07:749A..74AD を空けるためにそのままコピー
FUN_07_749a:
  dec a
  push af
  push de
  ld hl, $D813
  rst AddHL
  ld a, [hli]
  inc hl
  inc hl
  ld l, [hl]
  ld h, $14
  call multiply_8_8
  add l
  ld l, a
  pop de
  pop af
  ld h, $D9
  ret

; parameters:
;   a = first enemy tile ID, bc = width/height, e = enemies remaining, hl = dst
SetEnemyAttr::
  push_all
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
  set_wrambank 1
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
  ret

; parameters:
;  de = dst in VRAM, hl = src, bc = bytesize
_CopyTextboxBGToWindow::
  push af
  push bc
  push de
  set_vrambank 1
  call VRAMEnable
  push bc
.loop
    ld a, 7
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .loop
  pop bc
  set_vrambank 0
  pop de
  pop bc
  pop af
  call memcpy16 ; original
  call VRAMDisable
  ret

SECTION FRAGMENT "Free_247", ROM0
SetAllWhite:
  farcall LoadWhiteBGPalette
  ld hl, $D819 ; JP/US共通
  ret

ShowScreen:
  push hl
  ld hl, wPaletteBattle
  farcall LoadBGPalette
  pop hl
  call FUN_01D7
  ret

CopyTextboxBufferToVRAM:
  farcall _CopyTextboxBufferToVRAM
  jmp FUN_0186

CopyTextboxBGToWindow:
  farcall _CopyTextboxBGToWindow
  ret
