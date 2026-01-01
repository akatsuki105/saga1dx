SECTION FRAGMENT "RAMCodeLoader", ROMX, BANK[8]
LoadPaletteRAMCode::
  ld a, BANK(wPaletteCode)
  ld bc, PaletteCodeEnd - PaletteCode
  ld de, wPaletteCode
  ld hl, PaletteCode
  call CopyFarCodeToWRAM
  ret

SECTION "RAMCopiedCode_Palette", ROMX, BANK[8]
PaletteCode:
  LOAD "RAMCode_Palette", WRAMX[$D400], BANK[WRAM_PALETTE_BANK]
wPaletteCode:

wLoadWhiteBGPalette::
  ld a, $80
  ldh [rBGPI], a
  ld b, (WRAM_PALETTE_SIZE/8) ; rgb555 x 32色
.loop
    wait_blank
    ld a, $FF
rept 8
    ldh [rBGPD], a
endr
    dec b
    jr nz, .loop
  ret

wLoadWhiteOBJPalette::
  ; レジスタが変わっただけで wLoadWhiteBGPalette とやることは同じ
  ld a, $80
  ldh [rOBPI], a
  ld b, (WRAM_PALETTE_SIZE/8) ; rgb555 x 32色
.loop
    wait_blank
    ld a, $FF
rept 8
    ldh [rOBPD], a
endr
    dec b
    jr nz, .loop
  ret

wFillPaletteBlack::
  ld a, $80
  ldh [rBGPI], a
  ldh [rOBPI], a
  ld b, (WRAM_PALETTE_SIZE/4) ; rgb555 x 32色
.loop
    wait_blank
    xor a ; ここが黒に変わっただけで、 wLoadWhiteBGPalette とやることは同じ
rept 4
    ldh [rBGPD], a
    ldh [rOBPD], a
endr
    dec b
    jr nz, .loop
  ret

wLoadBGPalette::
  ; hl = palette addr (*u16)
  push af
  push bc
  ld a, $80
  ldh [rBGPI], a
  ld b, (WRAM_PALETTE_SIZE/8)
.loop
    wait_blank
rept 8
    ld a, [hli]
    ldh [rBGPD], a
endr
    dec b
    jr nz, .loop
  jp PopAndReturn + 2 ; bc, af

wLoadOBJPalette::
  ; hl = palette addr (*u16)
  push af
  push bc
  ld a, $80
  ldh [rOBPI], a
  ld b, (WRAM_PALETTE_SIZE/8) ; rgb555 x 32色
.loop
    wait_blank
rept 8
    ld a, [hli]
    ldh [rOBPD], a
endr
    dec b
    jr nz, .loop
  jp PopAndReturn + 2 ; bc, af

SetFade_Far::
  ; a = Gameboy BGP value
  push_all
  ld hl, wPaletteLookup
  ld l, a
  ld a, [hl]
  ; 直前のフェード値と同じなら画面は変化しないので何もしない
    ld c, a
    ld a, [wLastFadeValue]
    cp c
    jr z, .done
  ld a, c
  ld [wLastFadeValue], a
  cp 2
  jr nz, .dontResetPalette
  xor a
  ld [wIsTitle], a
.dontResetPalette
  ld hl, wPaletteBG
  ld a, [wRequestedPalette]
  add b
  swap a
  sla a
  sla a
  add l
  ld l, a
.loadBGPalette
  ; HL = HL + (0x100 * c)
  ld a, c
  add h
  ld h, a
  ld a, $80            ; Set index to first color + auto-increment
  ldh [rBGPI], a
  ld b, WRAM_PALETTE_SIZE
.loopBG
    wait_blank
    ld a, [hli]
    ldh [rBGPD], a
    dec b
    jr nz, .loopBG
.loadOBJPalette
  ld hl, wPaletteOBJ
  ; HL = HL + (0x100 * c)
  ld a, c
  add h
  ld h, a
  ld a, $80            ; Set index to first color + auto-increment
  ldh [rOBPI], a
  ld b, WRAM_PALETTE_SIZE
.loopOBJ
    wait_blank
    ld a, [hli]
    ldh [rOBPD], a
    dec b
    jr nz, .loopOBJ
.done
  jp PopAndReturn

  ENDL
PaletteCodeEnd:
