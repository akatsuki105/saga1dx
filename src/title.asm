SECTION "Title_Hook", ROMX[$7D9B], BANK[3]
  call InitializeTitleDX

; タイトルロゴがチラ見えしないようにしておく
SECTION "Title7E2D_Hook", ROMX[$7E31], BANK[3]
  ld a, $80
  ldh [rSCX], a
SECTION "Title7E66_Hook", ROMX[$7E66], BANK[3]
  ld a, $0
  ldh [rSCX], a

SECTION FRAGMENT "Free_247", ROM0
InitializeTitleDX:
  call FUN_03_7FDF
  farcall InitializeTitle_Far
  ret

SECTION FRAGMENT "bank8", ROMX
InitializeTitle_Far:
  ; タイトルロゴがチラ見えしないようにしておく
  call WaitForVBlank_ByHand
  ld a, $88
  ldh [rLCDC], a
  set_vrambank 1
  ld hl, TitleBGAttr
  ld de, TILEMAP0
  ld bc, $0240
  call VRAMEnable
.loopLoadBGAttr
rept 2
    ld a, [hli]
    ld [de], a
    inc de
    dec bc
endr
    ld a, b
    or c
    jr nz, .loopLoadBGAttr
  ; タイトルアニメーションのSaGaはウィンドウなので、属性マップをウィンドウにも設定する
  ld hl, TitleBGAttr + $A0
  ld de, TILEMAP1
  ld b, $70
.loopLoadWindowAttr
rept 4
    ld a, [hli]
    ld [de], a
    inc e ; 長さ的に inc de は不要
    dec b
endr
    jr nz, .loopLoadWindowAttr
  set_vrambank 0
  ld hl, InitialTitlePal
  ld a, $80            ; Set index to first color + auto-increment
  ldh [rBGPI], a    
  ld b, 64             ; 32 color entries=0x40 bytes
.loopTitleBGPAL
rept 8
    ld a, [hli]    ; 2t
    ldh [rBGPD], a ; 3t
    dec b          ; 1t
endr
    jr nz, .loopTitleBGPAL
  ld hl, InitialOBJPal
  ld a, $80            ; Set index to first color + auto-increment
  ldh [rOBPI], a
  ld b, 64             ; 32 color entries=0x40 bytes
.loopTitleOAMPAL
rept 8
    ld a, [hli]
    ldh [rOBPD], a
    dec b
endr
    jr nz, .loopTitleOAMPAL
  call VRAMDisable
  ret


; ; skip title animation in jp
; SECTION "TitleJP_Hook", ROMX[$7DB2], BANK[3]
;   jp $7E99
