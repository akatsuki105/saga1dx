; US: $7E2E
SECTION "Intro_Hook7F32", ROMX[$7F32], BANK[3]
  farcall IntroDX
  nop
  nop

SECTION FRAGMENT "bank8", ROMX
; a = Tile, bc = count, hl = dst
IntroDX:
  ld hl, TILEMAP0
  ld a, $7F
  push hl ; ループが2回あるので、hl, bcをスタックに保存
  push bc
  set_vrambank 1
  call VRAMEnable
.loop1
    ld a, $07
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop1
  pop bc
  pop hl
  push hl
  push bc
  set_vrambank 0
.loop2
    ld a, $7F
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop2
  call VRAMDisable
  pop bc
  pop hl
  ret
