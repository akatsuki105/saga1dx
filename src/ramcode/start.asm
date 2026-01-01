SECTION FRAGMENT "RAMCodeLoader", ROMX, BANK[8]
LoadSaGa1Initialize::
  ld a, BANK(wSaGa1Initialize)
  ld bc, SaGa1InitializeEnd - SaGa1Initialize
  ld de, wSaGa1Initialize
  ld hl, SaGa1Initialize
  call CopyFarCodeToWRAM
  ret

SECTION "RAMCopiedCode_Start", ROMX, BANK[8]
SaGa1Initialize:
  LOAD "RAMCode_Start", WRAMX[$D000], BANK[WRAM_SCRATCH_BANK]
wSaGa1Initialize::
  di
  ld a, $80
  ldh [rLCDC], a
  xor a
  ldh [rIF], a
  ldh [rIE], a
  ldh [rSTAT], a
  ld l, $24
rept 3
  ld [hli], a
endr
  ldh [rSCX], a
  ldh [rSCY], a
  ld b, $01
  ld a, $1B
  ld hl, $C425
  push hl
  cp [hl]
  inc hl
  jr nz, .label0254
  cpl
  cp [hl]
  jr nz, .label0254
  ld b, $00
.label0254
  push bc
  xor a
  ld hl, STARTOF(WRAM0)
  ld bc, $0F00
  call memset16
  ; Don't clear D000, they use the whole thing for maps anyway
  ld hl, $FF80
  ld b, $7F
  call memset8
  pop bc
  pop hl
  ld a, $1B
  ld [hli], a
  cpl
  ld [hli], a
  ld [hl], b
  ld hl, $00F0
  ld de,$FF80
  ld b,$08
  call memcpy8
  ld   hl,$00DD
  ld   de,$C380
  ld   b,$13
  call memcpy8
  ld   hl, wRandSeeds
  ld   b, $80
.label0291
  ldh a, [rDIV]
  ld [hli], a
  dec b
  jr nz, .label0291
  xor a
  ld hl, $FF88
  ld [hl], 1
  inc hl
  ld [hld], a
  ld c, a
.label02A0
  push hl
  ld a, [hli]
  ld h, [hl]
  ld   l,a
  ld   de, $0B
  call multiply_16_16
  ld   hl,$0400
  call divide_16_16
  push hl
  pop  de
  ld  a, d
  cp  $2
  jr c, .label02C2
  inc e
  dec e
  jr z, .label02C2
  xor  a
  sub  e
  ld   e, a
  ld   a, $04
  sbc  d
  ld   d, a
.label02C2
  pop hl
  ld [hl], e
  inc hl
  ld [hl], d
  dec hl
  srl  d
  rr   e
  ld  a, e
  ld  b, $CB
  ld  [bc], a ; bc = wRandTable (0xCB00)
  inc c
  jr nz, .label02A0
  ld a, $07
  rst SwitchBank
  call UpdateAudio
  di
  xor a
  ldh [rLYC], a
  ldh [rIF], a
  ld a, (IE_VBLANK | IE_STAT)
  ldh [rIE], a
  ld a, STAT_LYC
  ldh [rSTAT], a
  ld hl, $C39A
  ld a, $C3
  ld [hli], a
  ld a, $B9
  ld [hli], a
  ld a, $06
  ld [hli], a
  call FUN_0435
  ld a, $3
  rst SwitchBank
  ld de, $7100
  ld hl, $9000
  ld bc, $3B8
  call FUN_0423
.label0304 ; US: label0311
  ld a, [de]
  inc de
  ld [hli], a
  ld [hli], a
  dec bc
  ld a, c
  or b
  jr nz, .label0304
  ld b, $90
  call Swap_DE_HL
  call memcpy8
  ld  hl, $7A00
  ld  de, $8800
  ld  b, $04
  ld  a, $02
  call memcpy16_far ; 02:7A00 -> 8800
  ld  hl,$7F00
  ld  d,$8F
  ld  a,$02
  call memcpy8_far ; 02:7F00 -> 8F00 (256 Bytes)
  call FUN_0434
  ret
  ENDL
SaGa1InitializeEnd:
