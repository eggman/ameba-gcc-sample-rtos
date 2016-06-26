.SUFFIXES: .o .a .c .s

DEV_NUL=/dev/null

RM=rm -f

CROSS_COMPILE = arm-none-eabi-
AR = $(CROSS_COMPILE)ar
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
NM = $(CROSS_COMPILE)nm
SIZE = $(CROSS_COMPILE)size

vpath %.c ./src

INCLUDES  = -Isdk/component/soc/realtek/8195a/cmsis/device
INCLUDES += -Isdk/component/soc/realtek/8195a/fwlib/rtl8195a
INCLUDES += -Isdk/component/soc/realtek/8195a/fwlib
INCLUDES += -Isdk/component/soc/realtek/common/bsp
INCLUDES += -Isdk/component/soc/realtek/8195a/cmsis
INCLUDES += -Isdk/component/soc/realtek/8195a/cmsis/device
INCLUDES += -Isdk/component/os/freertos
INCLUDES += -Isdk/component/os/freertos/freertos_v8.1.2/Source/include
INCLUDES += -Isdk/component/os/freertos/freertos_v8.1.2/Source/portable/GCC/ARM_CM3
INCLUDES += -Isdk/component/common/api/wifi
INCLUDES += -Isdk/component/common/drivers/wlan/realtek/include
INCLUDES += -Isdk/component/common/drivers/wlan/realtek/src/osdep
INCLUDES += -Isdk/component/common/drivers/sdio/realtek/sdio_host/inc
INCLUDES += -Isdk/component/common/mbed/hal
INCLUDES += -Isdk/component/common/mbed/hal_ext
INCLUDES += -Isdk/component/common/mbed/targets/hal/rtl8195a
INCLUDES += -Isdk/project/realtek_ameba1_va0_example/inc

OUTPUT_PATH=build

CFLAGS = -c
CFLAGS += -g
CFLAGS += -w
CFLAGS += -mcpu=cortex-m3
CFLAGS += -mtune=cortex-m3
CFLAGS += -mthumb
CFLAGS += -O2
CFLAGS += -ansi
CFLAGS += -std=gnu99
CFLAGS += -fno-short-enums
CFLAGS += -fno-common
CFLAGS += -fmessage-length=0
CFLAGS += -Wall
CFLAGS += -fno-exceptions
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
CFLAGS += -fomit-frame-pointer
CFLAGS += -fno-short-enums
CFLAGS += -nostdlib
CFLAGS += -Werror
CFLAGS += -Wundef
CFLAGS += -Wpointer-arith
CFLAGS += -Wstrict-prototypes
CFLAGS += -Wno-write-strings
CFLAGS += -fsingle-precision-constant
CFLAGS += -Wdouble-promotion
CFLAGS += -nostartfiles
CFLAGS += -DCONFIG_PLATFORM_8195A $(INCLUDES)
CFLAGS += $(CFLAGS_MOD)

ASFLAGS = -mcpu=cortex-m3 -mthumb -Wall -a -g $(INCLUDES)

C_SRC+=$(wildcard src/*.c)

C_OBJ_TEMP=$(patsubst %.c, %.o, $(notdir $(C_SRC)))

# during development, remove some files
C_OBJ_FILTER=

C_OBJ=$(filter-out $(C_OBJ_FILTER), $(C_OBJ_TEMP))

ELF_CFLAGS += -O2
ELF_CFLAGS += -Wl,--gc-sections
ELF_CFLAGS += -mcpu=cortex-m3
ELF_CFLAGS += -mthumb
ELF_CFLAGS += --specs=nano.specs

ELF_LDFLAGS += -Lsdk/lib -Lsdk/scripts -Tsdk/scripts/rlx8195A-symbol-v03-img2_arduino_arduino.ld 
ELF_LDFLAGS += -Wl,-Map=$(OUTPUT_PATH)/target.map 
ELF_LDFLAGS += -Wl,--cref
ELF_LDFLAGS += -Wl,--warn-common
ELF_LDFLAGS += -Wl,--gc-sections
ELF_LDFLAGS += -Wl,--no-enum-size-warning
ELF_LDFLAGS += -Wl,--no-wchar-size-warning
ELF_LDFLAGS += -Wl,--entry=InfraStart
ELF_LDFLAGS += -Wl,-nostdlib

ELF_ARLIST += ./sdk/lib/lib_platform.a
ELF_ARLIST += ./sdk/lib/lib_ameba.a
#ELF_ARLIST += ./sdk/lib/lib_wlan.a
#ELF_ARLIST += ./sdk/lib/lib_wlan_mp.a
#ELF_ARLIST += ./sdk/lib/lib_wps.a
#ELF_ARLIST += ./sdk/lib/lib_mdns.a
#ELF_ARLIST += ./sdk/lib/lib_rtlstd.a
#ELF_ARLIST += ./sdk/lib/lib_sdcard.a


all: $(OUTPUT_PATH)/target.axf

makebin/ram_all.bin: $(OUTPUT_PATH)/target.axf
	cd ./makebin && /bin/bash ./makebin.sh

$(OUTPUT_PATH)/target.axf: $(addprefix $(OUTPUT_PATH)/,$(C_OBJ))
	echo build all objects
	$(CC) $(ELF_CFLAGS) $(ELF_LDFLAGS) -o $(OUTPUT_PATH)/target.axf -Wl,--start-group $^ -Wl,--end-group $(ELF_ARLIST) -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys
	$(SIZE) $(OUTPUT_PATH)/target.axf 

$(addprefix $(OUTPUT_PATH)/,$(C_OBJ)): $(OUTPUT_PATH)/%.o: %.c
	@echo "$(CC) -c $(CFLAGS) $< -o $@"
	@"$(CC)" -c $(CFLAGS) $< -o $@

clean:
	@echo clean
	-@$(RM) $(OUTPUT_PATH)/target.* 1>$(DEV_NUL) 2>&1
	-@$(RM) $(OUTPUT_PATH)/*.d 1>$(DEV_NUL) 2>&1
	-@$(RM) $(OUTPUT_PATH)/*.o 1>$(DEV_NUL) 2>&1
	-@$(RM) $(OUTPUT_PATH)/*.i 1>$(DEV_NUL) 2>&1
	-@$(RM) $(OUTPUT_PATH)/*.s 1>$(DEV_NUL) 2>&1
	-@$(RM) ./makebin/target* 1>$(DEV_NUL) 2>&1
	-@$(RM) ./makebin/*.bin 1>$(DEV_NUL) 2>&1

