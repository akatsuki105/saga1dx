SECTION "ReplaceFarCall", ROM0[$0180]
  jmp FarCall2

SECTION FRAGMENT "Free_247", ROM0
; SaGa2 の FarCall
; ネストしても壊れないしWRAMサイズも小さい優れもの
FarCall2::
  push af
  push hl
  push de
  ld hl, sp+$6
  ld a, [hl]
  ld e, a
  add $3
  ld [hli], a
  ld d, [hl]
  jr nc, .lab_04cd
  inc [hl]
.lab_04cd
  ld l, e
  ld h, d
  ld a, [hli]
  ld [wFarCall2.Dst], a
  ld a, [hli]
  ld [wFarCall2.Dst+1], a
  ld a, [hl]
  rst SwitchBank
  ld e, a
  ld hl, sp+$5
  ld a, [hl]
  di
  ld [hl], e
  ld [wFarCall2.A], a
  pop de
  pop hl
  pop af
  dec sp
  ei
  call wFarCall2
  push af
  push hl
  ld hl, sp+$4
  ld a, [hl]
  rst SwitchBank
  pop hl
  pop af
  inc sp
  ret
