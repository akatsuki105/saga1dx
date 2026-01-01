; US: $2A9C
SECTION "MenuLoadTiles_Hook", ROM0[$2AA0]
  call MenuLoadTiles

; US: $2CF2
SECTION "ClearMenuBackground_Hook", ROM0[$2CF6]
  farcall wClearMenuBackground
  jp FUN_017D

; US: $35A1
SECTION "ClearTextbox_Hook", ROM0[$3599]
  ; call ClearTextbox

SECTION "MenuLoadTiles_Hook7AF7", ROMX[$7AF7], BANK[3]
  ld de, $9C00
  ld bc, $1412
  call MenuLoadTiles

; US: $144F
SECTION "Free_MenuCode", ROM0
MenuLoadTiles:
  farcall wMenuLoadTiles
  ret

; US: $1456, バニラのバグ修正のコード
ClearTextbox:
  ; farcall wClearTextbox
  ; call $14E4
  ; ret

