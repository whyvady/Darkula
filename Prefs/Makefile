TARGET := iphone:clang:latest:12.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = darkulaprefs

darkulaprefs_FILES = $(wildcard Controllers/*.m)
darkulaprefs_INSTALL_PATH = /Library/PreferenceBundles
darkulaprefs_FRAMEWORKS = UIKit
darkulaprefs_PRIVATE_FRAMEWORKS = Preferences
darkulaprefs_CFLAGS = -fobjc-arc -IControllers -I../Shared

include $(THEOS_MAKE_PATH)/bundle.mk
