SECTION "HRAM_FF80", HRAM[$FF80]
hOAMDMACode::
  ; _RunOAMDMA のRAMコード
  ; OAMDMA中はHRAM以外へアクセスできないので、OAMDMAを起動するコードはHRAMに置く必要がある
  ; RunOAMDMA (rst $18) で呼び出す
  ds 8

SECTION "HRAM_FF88", HRAM[$FF88]
hFF88:: db
hFF89:: db

SECTION "HRAM_FF8B", HRAM[$FF8B]
hCurrentROMBank:: db


