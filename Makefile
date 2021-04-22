SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PeepReborn

ARCHS = arm64 arm64e


PeepReborn_FILES = PeepReborn.x
PeepReborn_CFLAGS = -fobjc-arc
PeepReborn_EXTRA_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
