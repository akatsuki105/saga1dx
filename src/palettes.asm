; Hooks

SECTION "SetFade3DD0_Hook", ROM0[$3DC8]
  farcall FillPaletteBlack
  ret

SECTION "SetFade3DE2_Hook", ROM0[$3DDA]
  call SetPaletteNormal
  ret

SECTION "SetFade7D62_Hook", ROMX[$7D5D], BANK[3]
  ds 5, $00 ; nop * 5

; --------------------------

SECTION FRAGMENT "Free_247", ROM0
SetPaletteNormal:
  push hl
  ld hl, wPaletteBG
  farcall LoadBGPalette
  ld hl, wPaletteOBJ
  farcall LoadOBJPalette
  pop hl
  ret

; --------------------------

SECTION FRAGMENT "bank8", ROMX
InitializeFadeLookup:
  push_all
  set_wrambank WRAM_PALETTE_BANK
  ld hl, wPalettes
  ld c, 1
  ld b, $FF
  call LoadFadeLevel
  ld hl, wPalettes + (WRAM_PALETTE_SIZE * 8)
  ld b, $FF
  call LoadFadeBlack
  set_wrambank 1
  pop_all
  ret

LoadFadeLevel:
  push_all
  inc c
  srl b
.loopColor
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    push bc
.loopFade
      dec c
      jr z, .doneFade
      ld a, d
      and $7B
      srl a
      ld d, a
      ld a, e
      rr a
      and $EF
      ld e, a
      jr .loopFade
.doneFade
    pop bc
    push hl
    ; HL = HL - 2 + (0x100 * (c - 1))
      ld a, c
      dec a
      add h
      ld h, a
      dec l
      dec l
    call FUN_0043
    pop hl
    dec b
    jr nz, .loopColor
  jp PopAndReturn

LoadFadeBlack:
  ; hl = dst, b = size
  push af
  push bc
  xor a
.loop
    ld [hli], a
    dec b
    jr nz, .loop
  jp PopAndReturn + 2 ; bc, af

LoadPaletteRAMData::
  set_wrambank WRAM_PALETTE_BANK
  xor a
  ld [wIsTitle], a ; [wIsTitle] = 0
  dec a
  ld [wLastFadeValue], a ; [wLastFadeValue] = 0xFF
  ; Load DX Palette Data
    ld bc, InitialPalEnd - InitialPal
    ld de, wPalettes
    ld hl, InitialPal
    call memcpy16
  call InitializeFadeLookup
  ; Load DX Palette Lookup Data
    ld bc, PaletteLookupEnd - PaletteLookup
    ld de, wPaletteLookup
    ld hl, PaletteLookup
    call memcpy16
  set_wrambank 1
  ret

LoadBGPalette::
  ; hl = palette addr (*u16)
  push af
  push bc
  ld a, $80
  ldh [rBGPI], a
  ld b, (PAL_SIZE * 8)
  call VRAMEnable
  set_wrambank WRAM_PALETTE_BANK
.loop
    ld a, [hli]
    ldh [rBGPD], a
    dec b
    jr nz, .loop
  set_wrambank 1
  call VRAMDisable
  pop bc
  pop af
  ret

LoadOBJPalette:
  ; hl = palette addr (*u16)
  push af
  push bc
  ld a, $80
  ldh [rOBPI], a
  ld b, (PAL_SIZE * 8)
  call VRAMEnable
  set_wrambank WRAM_PALETTE_BANK
.loop
    ld a, [hli]
    ldh [rOBPD], a
    dec b
    jr nz, .loop
  set_wrambank 1
  call VRAMDisable
  pop bc
  pop af
  ret

LoadWhiteBGPalette::
  ld a, $80
  ldh [rBGPI], a
  ld b, (WRAM_PALETTE_SIZE/8) ; rgb555 x 32色
  call VRAMEnable
.loop
    ld a, $FF
rept 8
    ldh [rBGPD], a
endr
    dec b
    jr nz, .loop
  call VRAMDisable
  ret

FillPaletteWhite::
  ld a, $FF ; RGB 31, 31, 31
  jr FillPalette
FillPaletteBlack::
  xor a
  ; fallthrough

; parameters:
;  a = color to fill
FillPalette::
  push bc
  push af
  ld a, $80
  ldh [rBGPI], a
  ldh [rOBPI], a
  call VRAMEnable
  ld b, (PAL_SIZE * 8)
  pop af
.loop
    ldh [rBGPD], a
    ldh [rOBPD], a
    dec b
    jr nz, .loop
  call VRAMDisable
  pop bc
  ret
