; バニラ(SaGa1)の関数ラベル定義 (DEF だと ROMバンク指定できないので)

SECTION "rst00", ROM0[$0000]
; parameters:
;  hl = value, a = addend
; returns:
;  hl = hl + a
AddHL::

SECTION "Swap_DE_HL", ROM0[$000B]
Swap_DE_HL::

SECTION "rst10", ROM0[$0010]
WaitForVBlank::

SECTION "PopAndReturn", ROM0[$0013]
; pop hl
; pop de
; pop bc
; pop af
; ret
; するだけ、 関数の最後で jp PopAndReturn することでサイズを節約できるぞ
PopAndReturn::

SECTION "rst18", ROM0[$0018]
; HRAMコードの  hOAMDMACode を実行する
RunOAMDMA::

SECTION "rst28", ROM0[$0028]
; 内部で IME=1 されることに注意
; parameters:
;  a = ROMバンク
; returns:
;  a = previous ROMバンク
SwitchBank::

SECTION "FUN_003B", ROM0[$003B]
; *((*u16)hl)++ = bc;
FUN_003B::

SECTION "FUN_0043", ROM0[$0043]
; *((*u16)hl)++ = de;
FUN_0043::

SECTION "memclear8", ROM0[$007B]
; parameters:
;  hl = dst, b = length (0 = 256)
memclear8::

SECTION "memset8", ROM0[$007C]
; parameters:
;  hl = dst, a = value, b = length(0 = 256)
; returns:
;  hl = dst + length
memset8::

SECTION "memclear16", ROM0[$0081]
; 256バイト以上の長さを指定できる代わりにちょっと遅くなった memclear8
; parameters:
;  hl = dst, bc = byte length
memclear16::

SECTION "memset16", ROM0[$0082]
memset16::
SECTION "memcpy8", ROM0[$008F]
memcpy8::
SECTION "memcpy16", ROM0[$0098]
memcpy16::
SECTION "vramset16", ROM0[$00AC]
vramset16::
SECTION "vramcpy16", ROM0[$00BE]
vramcpy16::

SECTION "TemplateC380", ROM0[$00DD]
TemplateC380::

SECTION "_RunOAMDMA", ROM0[$00F0]
; OAMDMAを実行する
; この関数を直接呼び出すのではなく、 HRAM にコピーしたこのコード(hOAMDMACode) を rst18 で呼び出している
_RunOAMDMA::

SECTION "multiply_8_8", ROM0[$015F]
multiply_8_8:: ; jp _multiply_8_8

SECTION "VRAMEnable", ROM0[$017A]
VRAMEnable:: ; jp _VRAMEnable
SECTION "VRAMDisable", ROM0[$017D]
VRAMDisable:: ; jp _VRAMDisable

SECTION "FarCall", ROM0[$0180]
; 別のROMバンクにある関数を呼び出す
; 見たところ、呼び出し元のレジスタはすべて渡して、リターンのときもレジスタを全て呼び出し先に渡している
FarCall:: ; jp _FarCall

SECTION "FUN_0186", ROM0[$0186]
FUN_0186:: ; jp _FUN_0186

SECTION "FUN_01D7", ROM0[$01D7]
FUN_01D7::

SECTION "WaitForVBlank_ByHand", ROM0[$01DD]
WaitForVBlank_ByHand::

SECTION "memcpy8_far", ROM0[$0200]
memcpy8_far::

SECTION "memcpy16_far", ROM0[$0207]
; parameters:
;  de = dst, a:hl = src, bc = byte length
memcpy16_far::

SECTION "vramcpy8_far", ROM0[$020E]
vramcpy8_far::

SECTION "_VRAMEnable", ROM0[$0423]
_VRAMEnable:: ; US: 043D
SECTION "_VRAMDisable", ROM0[$0434]
_VRAMDisable:: ; US: 044E
SECTION "VRAMDisableImmediately", ROM0[$0435]
VRAMDisableImmediately:: ; US: 044F

SECTION "_FUN_0186", ROM0[$0454]
_FUN_0186::

SECTION "_FarCall", ROM0[$0469]
; このパッチでは FarCall2 を使うようにしたので、このコードは使われない
_FarCall::

SECTION "VBlank", ROM0[$06B9]
VBlank::

SECTION "_multiply_8_8", ROM0[$071C]
_multiply_8_8::

SECTION "multiply_16_16", ROM0[$0733]
multiply_16_16:: ; US: $074D

SECTION "divide_16_16", ROM0[$0759]
divide_16_16:: ; US: $0773

SECTION "FUN_14E4", ROM0[$14E4]
FUN_14E4::

; ------------------ ROM1 --------------------

SECTION "PlayerTileData", ROMX[$6000], BANK[1]
; キャラクタの2bppタイルデータ
PlayerTileData::

; ------------------ ROM2 --------------------

SECTION "TitleTiledata", ROMX[$7A00], BANK[2]
TitleTiledata::

SECTION "SphereTileData", ROMX[$7E00], BANK[2]
SphereTileData::

SECTION "MiscTileData", ROMX[$7F00], BANK[2]
; ゴミ箱アイコン や ©︎ などのその他のタイルの2bppタイルデータ
MiscTileData::

; ------------------ ROM3 --------------------

SECTION "FontTileData", ROMX[$7100], BANK[3]
FontTileData::

SECTION "Scene_Title", ROMX[$7D50], BANK[3]
Scene_Title::

SECTION "FUN_03_7FDF", ROMX[$7FDF], BANK[3]
FUN_03_7FDF:: ; US: $7EC3

; ------------------ ROM4 --------------------

SECTION "ROM4", ROMX[$4000], BANK[4]
EnemyTileData:: ; このバンク全部が敵キャラの2bppタイルデータ

; ------------------ ROM6 --------------------

SECTION "LoadBattleScreenGraphic", ROMX[$5E35], BANK[6]
LoadBattleScreenGraphic::

; ------------------ ROM7 --------------------

SECTION "ResetAudio", ROMX[$4000], BANK[7]
ResetAudio::
SECTION "UpdateAudio", ROMX[$4003], BANK[7]
UpdateAudio::
