# Makefile to build libcart

include util.mk

# Preprocessor definitions
DEFINES := _ULTRA64=1

SRC_DIRS :=

# Whether to hide commands or not
VERBOSE ?= 0
ifeq ($(VERBOSE),0)
  V := @
endif

# Whether to colorize build messages
COLOR ?= 1

OPT_FLAGS := -Os -g

TARGET := libcart

#==============================================================================#
# Target Executable and Sources                                                #
#==============================================================================#
BUILD_DIR      := build
LIB            := $(BUILD_DIR)/$(TARGET).a

# Directories containing source files
SRC_DIRS += src

C_FILES           := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
S_FILES           := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.s))

# Object files
O_FILES := $(foreach file,$(S_FILES),$(BUILD_DIR)/$(file:.s=.o)) \
           $(foreach file,$(C_FILES),$(BUILD_DIR)/$(file:.c=.o))

# Automatic dependency files
DEP_FILES := $(O_FILES:.o=.d) $(ASM_O_FILES:.o=.d)

#==============================================================================#
# Compiler Options                                                             #
#==============================================================================#

AS        := mips-n64-as
CC        := mips-n64-gcc
CPP       := cpp
LD        := mips-n64-ld
AR        := mips-n64-ar

INCLUDE_DIRS += include /usr/include/n64 $(BUILD_DIR) $(BUILD_DIR)/include src .

C_DEFINES := $(foreach d,$(DEFINES),-D$(d))
DEF_INC_CFLAGS := $(foreach i,$(INCLUDE_DIRS),-I$(i)) $(C_DEFINES)

CFLAGS = -G 0 $(OPT_FLAGS) -mabi=32 -mfix4300 -mno-check-zero-division -ffreestanding -fno-common -fno-toplevel-reorder $(DEF_INC_CFLAGS) -Wall -Wextra -Wpedantic -fwrapv 
ASFLAGS =-G 0 $(OPT_FLAGS) -mabi=32 -mfix4300 $(foreach i,$(INCLUDE_DIRS),-I$(i)) $(foreach d,$(DEFINES),--defsym $(d))

# C preprocessor flags
CPPFLAGS := -P -Wno-trigraphs $(DEF_INC_CFLAGS)

# tools
PRINT = printf

ifeq ($(COLOR),1)
NO_COL  := \033[0m
RED     := \033[0;31m
GREEN   := \033[0;32m
BLUE    := \033[0;34m
YELLOW  := \033[0;33m
BLINK   := \033[33;5m
endif

# Common build print status function
define print
  @$(PRINT) "$(GREEN)$(1) $(YELLOW)$(2)$(GREEN) -> $(BLUE)$(3)$(NO_COL)\n"
endef

#==============================================================================#
# Main Targets                                                                 #
#==============================================================================#

# Default target
default: $(LIB)

clean:
	$(RM) -r $(BUILD_DIR)

ALL_DIRS := $(BUILD_DIR) $(addprefix $(BUILD_DIR)/,$(SRC_DIRS))

# Make sure build directory exists before compiling anything
DUMMY != mkdir -p $(ALL_DIRS)

#==============================================================================#
# Compilation Recipes                                                          #
#==============================================================================#

# Assemble assembly code
$(BUILD_DIR)/%.o: %.s
	$(call print,Assembling:,$<,$@)
	$(V)$(CC) -c $(CFLAGS) $(foreach i,$(INCLUDE_DIRS),-Wa,-I$(i)) -x assembler-with-cpp -MMD -MF $(BUILD_DIR)/$*.d  -o $@ $<

# Compile C code
$(BUILD_DIR)/%.o: %.c
	$(call print,Compiling:,$<,$@)
	$(V)$(CC) -c $(CFLAGS) -MMD -MF $(BUILD_DIR)/$*.d  -o $@ $<
$(BUILD_DIR)/%.o: $(BUILD_DIR)/%.c
	$(call print,Compiling:,$<,$@)
	$(V)$(CC) -c $(CFLAGS) -MMD -MF $(BUILD_DIR)/$*.d  -o $@ $<

# Link final ELF file
$(LIB): $(O_FILES)
	@$(PRINT) "$(GREEN)Linking $(TARGET):  $(BLUE)$@ $(NO_COL)\n"
	$(V)$(AR) rcs -o $@ $(O_FILES)

include install.mk

.PHONY: clean default install pkginstall
# with no prerequisites, .SECONDARY causes no intermediate target to be removed
.SECONDARY:

# Remove built-in rules, to improve performance
MAKEFLAGS += --no-builtin-rules

-include $(DEP_FILES)

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true
