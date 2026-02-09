
SECTION "Boot", ROM0
_Start::
  di
  ld sp, $D000
  set_rombank BANK(Init)
  call Init
.done
  jp $032F ; US: $0349

; SaGaのフォントデータは容量節約のため、 1bpp でVRAM展開時に 2bpp にしている
; なので単純な memcpy はできない
SECTION FRAGMENT "Free_247", ROM0
LoadPackedFont::
  ld a, BANK(FontTileData)
  rst SwitchBank
  push af
  ld de, FontTileData
  ld hl, $9000
  ld bc, $3B8
.loop
  ld a, [de]
  inc de
  ld [hli], a
  ld [hli], a
  dec bc
  ld a, c
  or b
  jr nz, .loop
  pop af
  rst SwitchBank
  ret

SECTION FRAGMENT "bank8", ROMX
Init::
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ldh [rSTAT], a
rept 3
  ld [rRAMG], a
endr
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rWX], a
	ldh [rWY], a
  lcd_off
; CGBの倍速モードを有効化
  ld hl, rSPD
  bit 7, [hl]
  jr nz, .get2xSpeed ; すでに倍速モード
  set 0, [hl]
  stop
  nop  ; rgbasmが自動でnopを挿入してくれるらしいが、明示的に書いておく
.get2xSpeed
  call ClearRAM
  call LoadPaletteRAMData
  call LoadSpriteAttrs
  call InitGame
.done
  ret

; ----------------------------------------------------------

; 既存のRAM + GBC化で増えたRAMバンク をクリア
ClearRAM:
  call ClearHRAM
  call ClearWRAMX
  call ClearVRAM
  ret

ClearHRAM::
  ld hl, STARTOF(HRAM)
  ld bc, SIZEOF(HRAM)
  call memclear8
  ret

; WRAM1..7 をクリア (WRAM0 は スタック とかですでに使うので全部クリアしてはいけない)
ClearWRAMX::
  ld a, 1 ; バンク番号
.loop
    push af
    ldh [rWBK], a
    ld hl, STARTOF(WRAMX)
    ld bc, SIZEOF(WRAMX)
    call memclear16
    pop af
    inc a
    cp 8
    jr c, .loop
  set_wrambank 1
  ret

; Wipe VRAM banks 0 and 1
ClearVRAM::
  set_vrambank 1
  call .clear
  set_vrambank 0
.clear
  ld hl, STARTOF(VRAM)
  ld bc, SIZEOF(VRAM)
  call memclear16 ; LCDオフなので普通に memclear16 でOK
  ret

; ----------------------------------------------------------

; SaGa1特有の初期化処理
InitGame::
  call InitHRAM
  call ResetWRAM0
  lcd_on
  farcall ResetAudio
  di ; multiply_16_16 など内部で retiしている関数がある(ただしここまでは IE = 0 なので IME = 1 でも問題なかった)
  ; ここからは IE = 0 じゃなくなる上に割り込み入ると困る時があるので di
.init_interrupts
  ; 割り込み状態の初期化
  xor a
  ldh [rLYC], a
  ldh [rIF], a
  ld a, (IE_VBLANK | IE_STAT)
  ldh [rIE], a
  ld a, STAT_LYC
  ldh [rSTAT], a
  ld hl, wVBlank
  ld a, $C3 ; jp
  ld [hli], a
  ld a, LOW(VBlank)
  ld [hli], a
  ld a, HIGH(VBlank)
  ld [hli], a
  call VRAMDisableImmediately
  call VRAMEnable
.load_assets
  call LoadPackedFont
  call LoadWindowBorderTileData
  call LoadTitleScreenTiles
  call LoadMiscTileData
.done
  call VRAMDisable ; IME = 1
  ret

ResetWRAM0:
  ld b, $01
  ld a, SENTINEL_SOFTRESET
  ld hl, wSoftResetSentinel
  ; check sentinel
  push hl
  cp [hl]
  inc hl
  jr nz, .clearWRAM0
  cpl
  cp [hl]
  jr nz, .clearWRAM0
  ld b, $00
.clearWRAM0
  push bc
  xor a
  ld hl, STARTOF(WRAM0)
  ld bc, $0F00
  call memset16 ; スタック以外($C000..CF00)を全部クリア
  pop bc
  pop hl ; hl = wSoftResetSentinel
  ; ClearWRAM0 で wSoftResetSentinel もクリアされているので再セット
  ld a, SENTINEL_SOFTRESET
  ld [hli], a
  cpl
  ld [hli], a
  ld [hl], b
  ; WRAMコードのコピー ($0281)
.copyWRAMCode
  ld hl, TemplateC380
  ld de, wC380
  ld b, $a
  call memcpy8
.setFarCall2
  ld a, $3E ; ld
  ld [wFarCall2], a
  ld a, $C3 ; jp
  ld [wFarCall2+2], a
.initRand ; $028C
  ; 乱数の初期化
  ld hl, wRandSeeds
  ld b, $80
.label0291
  ldh a, [rDIV]
  ld [hli], a
  dec b
  jr nz, .label0291
  ; clear wRandTable
  xor a
  ld hl, hFF88
  ld [hl], 1
  inc hl
  ld [hld], a
  ld c, a
.label02A0
  push hl
  ld a, [hli]
  ld h, [hl]
  ld l, a
  ld de, $B
  call multiply_16_16
  ld hl, $400
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
  ld  b, HIGH(wRandTable)
  ld  [bc], a
  inc c
  jr nz, .label02A0
  ret

InitHRAM::
  ld a, BANK(@)
  ldh [hCurrentROMBank], a
  ; HRAMコードのコピー ($0276)
  ld de, hOAMDMACode
  ld hl, _RunOAMDMA
  ld b, $8
  call memcpy8
  ret

; ウィンドウ枠のタイルデータ読み込み(フォントと連続して配置されているが、こっちは圧縮されていないので別途処理する)
LoadWindowBorderTileData:
  ld de, $9770                  ; dst
  ld hl, FontTileData + $3B8    ; src (addr)
  ld a, BANK(FontTileData)      ; src (bank)
  ld b, $90                     ; size
  call memcpy8_far
  ret

; タイトル画面のタイルデータ読み込み
LoadTitleScreenTiles:
  ld  de, $8800                 ; dst
  ld  hl, TitleTiledata         ; src (addr)
  ld  a, BANK(TitleTiledata)    ; src (bank)
  ld  bc, $400                  ; size
  call memcpy16_far
  ret

LoadMiscTileData:
  ld  de, $8F00                 ; dst
  ld  hl, MiscTileData          ; src (addr)
  ld  a, BANK(MiscTileData)     ; src (bank)
  ld  b, $0                     ; size (0 = 256)
  call memcpy8_far
  ret
