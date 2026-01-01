; Hooks

SECTION "SetFade3DD0_Hook", ROM0[$3DC8]
  call SetPaletteBlack
  ret

SECTION "SetFade3DE2_Hook", ROM0[$3DDA]
  call SetPaletteNormal
  ret

SECTION "SetFade7D62_Hook", ROMX[$7D5D], BANK[3]
  ds 5, $00 ; nop * 5

; --------------------------

SECTION "Free_FadeCode", ROM0
SetPaletteBlack:
  farcall wFillPaletteBlack
  ret

SetPaletteNormal:
  push hl
  ld hl, wPaletteBG
  call LoadBGPalette
  ld hl, wPaletteOBJ
  call LoadOBJPalette
  pop hl
  ret

LoadBGPalette::
  ; hl = Palette address
  farcall wLoadBGPalette
  ret

LoadOBJPalette:
  ; hl = Palette address
  farcall wLoadOBJPalette
  ret

LoadWhiteBGPalette::
  farcall wLoadWhiteBGPalette
  ret
  PRINTLN STRFMT("Free_FadeCode size: %d bytes", @ - SetPaletteBlack)

; --------------------------

SECTION "PaletteCode", ROMX, BANK[8]
InitializeFadeLookup:
  di
  push_all
  set_wrambank WRAM_PALETTE_BANK
  ld hl, wPalettes
  ld c, 1
  ld b, $FF
  call LoadFadeLevel
  ld hl, wPalettes + (WRAM_PALETTE_SIZE * 8)
  ld b, $FF
  call LoadFadeBlack
  reset_wrambank
  pop_all
  reti

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

SECTION FRAGMENT "RAMDataLoader", ROMX, BANK[8]
LoadPaletteRAMData::
  set_wrambank WRAM_PALETTE_BANK
  xor a
  ld [wIsTitle], a ; [wIsTitle] = 0
  dec a
  ld [wLastFadeValue], a ; [wLastFadeValue] = 0xFF
  ; Load DX Palette Data
    ld a, BANK(wPalettes)
    ld bc, InitialPalEnd - InitialPal
    ld de, wPalettes
    ld hl, InitialPal
    call CopyFarCodeToWRAM
  call InitializeFadeLookup
  ; Load DX Palette Lookup Data
    ld a, BANK(wPaletteLookup)
    ld bc, PaletteLookupEnd - PaletteLookup
    ld de, wPaletteLookup
    ld hl, PaletteLookup
    call CopyFarCodeToWRAM
  ret
