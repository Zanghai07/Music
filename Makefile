TARGET := iphone:clang:10.3:10.0
ARCHS := armv7

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME := MusicPlayer

MusicPlayer_FILES := Sources/main.m
MusicPlayer_FRAMEWORKS := UIKit MediaPlayer QuartzCore
MusicPlayer_CFLAGS := -fno-objc-arc
MusicPlayer_CODESIGN_FLAGS := -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
