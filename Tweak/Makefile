TARGET := iphone:clang:latest:12.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = darkula

darkula_FILES = $(wildcard Core/*.m) $(wildcard Debug/*.m) $(wildcard Apps/*.xm) $(wildcard Views/*.xm) $(wildcard Bars/*.xm) $(wildcard Input/*.xm) $(wildcard Effects/*.xm) $(wildcard Status/*.xm)
darkula_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -ICore -I../Shared
darkula_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
