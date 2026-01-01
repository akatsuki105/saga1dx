INCDIRS := src/include/
PREINCLUDES := src/include/hardware.inc src/include/definitions.inc src/include/macros/macros.inc
WARNINGS := all extra
ASFLAGS = -p ${PADVALUE} $(addprefix -I,${INCDIRS}) $(addprefix -P,${PREINCLUDES}) $(addprefix -W,${WARNINGS})
LDFLAGS = -p ${PADVALUE}
FIXFLAGS = -p ${PADVALUE} -i "${GAMEID}" -k "${LICENSEE}" -l ${OLDLIC} -m ${MBC} -n ${VERSION} -r ${SRAMSIZE} -t ${TITLE}

VANILLA = ${ROMNAME}.gb
ROM = build/${ROMNAME}.gbc
IPS = build/${ROMNAME}DX.ips
SRCS := $(shell find src -type f -name '*.asm')
OBJS := $(patsubst src/%.asm,obj/%.o,${SRCS})
DEPFILES := ${OBJS:.o=.mk}

include project.mk

.PHONY: all ips clean
all: ${ROM}

ips: ${IPS}

clean:
	rm -rf build obj

${ROM}: ${OBJS}
	@mkdir -p "${@D}"
	rgblink ${LDFLAGS} -l layout.link -n patch.sym -m patch.map -o $@ -O ${VANILLA} $^
	rgbfix -v ${FIXFLAGS} $@

${IPS}: ${ROM}
	flips --create --ips ${VANILLA} $< $@

obj/%.o: obj/%.mk
	@touch -c $@

obj/%.mk: src/%.asm
	@mkdir -p "${@D}"
	rgbasm ${ASFLAGS} -o ${@:.mk=.o} $< -M $@ -MG -MP -MQ ${@:.mk=.o} -MQ $@
