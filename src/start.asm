
SECTION "Free_Start", ROM0
_Start::
  ; DXInitialize
  ld a, 1
  ldh [rSPD], a
  stop ; rgbasm adds a nop after this instruction by default
Reboot:
  ld sp, STARTOF(WRAMX)
  set_rombank 8
  call InitializeSystem
  set_rombank 1

  set_wrambank WRAM_SCRATCH_BANK
  call wSaGa1Initialize
  reset_wrambank
  jp $032F ; US: $0349
  PRINTLN STRFMT("Free_Start size: %d bytes", @ - _Start)

SECTION "GameOverVector", ROMX[$6298], BANK[6]
  jp Reboot
