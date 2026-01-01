; US: $7E2E
SECTION "Intro_Hook7F37", ROMX[$7F37], BANK[3]
  call Intro

SECTION "Free_IntroCode", ROM0
Intro:
  di
  set_rombank 8
  call Intro_Far
  set_rombank 3
  reti
  PRINTLN STRFMT("Free_IntroCode size: %d bytes", @ - Intro)

SECTION "IntroFarCode", ROMX, BANK[8]
; a = Tile, bc = count, hl = dst
Intro_Far:
  push hl ; ループが2回あるので、hl, bcをスタックに保存
  push bc
  set_vrambank 1
.loop1
    wait_blank
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
  reset_vrambank
.loop2
    wait_blank
    ld a, $7F
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loop2
  pop bc
  pop hl
  ret
