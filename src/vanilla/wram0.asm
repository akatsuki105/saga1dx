SECTION "wOAM1", WRAM0[$C000]
wOAM1::
  ds $A0

; C0A0..C0FF は 戦闘中の処理(フレアなどのエフェクト)に使われるっぽい

SECTION "wOAM2", WRAM0[$C100]
; キャラクターのアニメーション用
wOAM2::
  ds $A0

SECTION "wRandSeeds", WRAM0[$C300]
wRandSeeds:: ds $80

SECTION "wC380", WRAM0[$C380]
wC380::

SECTION "wFarCall", WRAM0[$C38A]
; 初期化時に $00E7..00EF のコードがコピーされる
; FarCall が ? 部分を目的の値に書き換えてからここにジャンプする
; このパッチでは FarCall2 (SaGa2 で使われている FarCall) を使うようにしたので、このコードは使われない
wFarCall::

SECTION "wVBlank", WRAM0[$C39A]
wVBlank::
  ds 3 ; call VBlank

SECTION "wSoftResetSentinel", WRAM0[$C425]
wSoftResetSentinel::
  dw ; ゲームがソフトリセットしたかどうかを検出するために使用されるセンチネル値 (0xE41B)
wBooted::
  db ; ゲームの初回起動時に 1 にセットされる

SECTION "wRandTable", WRAM0[$CB00]
wRandTable::
  ds $100
