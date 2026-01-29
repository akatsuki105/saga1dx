; WRAM1 (0xD000-0xDFFF) はゲームのシーンによって内容が変わる

SECTION UNION "WRAM1", WRAMX
; Overworld scene
wTilemap::
  ds $1000

SECTION UNION "WRAM1", WRAMX
; Battle scene
wBattleStates::
  ds $3E9 ; TODO
wBattleEnemyID::
  dw
  dw
  dw
wBattleStatesUnknown::
  ds $E000 - $D3EF
