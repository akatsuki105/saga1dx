DEF BACKUP_A EQU $FFA1
DEF BACKUP_B EQU $FFA2
DEF BACKUP_C EQU $FFA3
DEF BACKUP_D EQU $FFA4
DEF BACKUP_E EQU $FFA5
DEF BACKUP_H EQU $FFA6
DEF BACKUP_L EQU $FFA7

DEF FARJUMP EQU $FFA8

SECTION "Free_FarCall", ROM0
FarCall::
  di
  ; Stash args someplace else
  ldh [BACKUP_A], a
  ld a, l
  ldh [BACKUP_L], a
  ld a, h
  ldh [BACKUP_H], a
  ; 48 cycles

  ; Get current return address into HL
  pop hl
rept 3
  inc hl
endr
  push hl
rept 3
  dec hl
endr
  ; 96 cycles

  ; Set RAMBANK (farcall の1バイト後)
  ld a, [hli]
  ldh [rWBK], a
  ; 116 cycles

  ; Get RAMADDR jp command into $F8~FA
  ld a, $C3 ; $C3 = jp u16
  ldh [FARJUMP + $00], a
  ld a, [hli] ; farcall の2バイト後
  ldh [FARJUMP + $01], a
  ld a, [hl] ; farcall の3バイト後
  ldh [FARJUMP + $02], a
  ; 176 cycles

  ; Replace return vector
  ld hl, .return
  push hl
  ; 204 cycles

  ; Get args back
  ldh a, [BACKUP_H]
  ld h, a
  ldh a, [BACKUP_L]
  ld l, a
  ldh a, [BACKUP_A]
  ; 248 cycles

  jp FARJUMP
  ; 264 cycles

.return
  ; Reset the RAMBANK
  push af
  reset_wrambank
  pop af
  reti
  PRINTLN STRFMT("Free_FarCall size: %d bytes", @ - FarCall)
  ; 320 cycles vs approximately 64 cycles for a hard coded RAM call

SECTION "SystemCode", ROMX, BANK[8]
; parameters:
;  a:  destination WRAM bank
;  de = dst, hl = src, bc = length
CopyFarCodeToWRAM::
  ldh [rWBK], a
.loop
    ld a, [hli]
    ld [de], a
    inc de
    dec bc ; dec bc does not set the z flag for some dumb reason, so oring b and c here
    ld a, b
    or c
    jr nz, .loop
  reset_wrambank
  ret

InitializeSystem::
  ; Several initialize sequences strung together without rets
  ld c, $80
.loop1 ; clear HRAM
    xor a
    ldh [c], a
    inc c
    jr nz, .loop1
; WRAM1..8
  ld b, $1 ; WRAM1
.loop2 ; initialize WRAM bank
    ld a, b
    ldh [rWBK], a
    ld hl, STARTOF(WRAMX)
.loop3 ; initialize WRAMX
      xor a
      ld [hli], a
      ld a, h
      cp $E0 ; check (hl < $E000)
      jp c, .loop3
    inc b
    ld a, b
    cp $8 ; check (b < 8)
    jp c, .loop2
  set_vrambank 1
  ld hl, $9000
  ld bc, $1000
.loopClearVRAM1
    wait_blank
    xor a
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .loopClearVRAM1
  reset_vrambank
.loadWRAM
  call LoadSaGa1Initialize
  call LoadMenuRAMCode
  call LoadBattleRAMCode
  call LoadMetatileRAMCode
  call LoadPaletteRAMData
  call LoadPaletteRAMCode
  call LoadSpriteRAMCode
  call LoadSpriteAttrs
  ret
