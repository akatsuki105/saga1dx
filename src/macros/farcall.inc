; SaGa1 に元から存在する FarCall
; 別のROMバンクの関数を呼び出して戻ってくる, 内部で IME=1 されることに注意
MACRO farcall ; rombank, address
  call FarCall
  dw \1
  db BANK(\1)
ENDM


MACRO farcall2 ; rombank, address
  call FarCall2
  dw \1
  db BANK(\1)
ENDM
