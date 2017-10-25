LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := cpp_on_android_sample
LOCAL_CFLAGS += -fPIE \
	-I../ -std=c++11
LOCAL_LDFLAGS += -fPIE -pie
LOCAL_SRC_FILES  := ../src/main.cpp
include $(BUILD_EXECUTABLE)


