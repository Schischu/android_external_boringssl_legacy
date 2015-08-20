# Note that some host libraries have the same module name as the target
# libraries. This is currently needed to build, for example, adb. But it's
# probably something that should be changed.

LOCAL_PATH := $(call my-dir)

## libcrypto

# Target static library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libcrypto_static
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/crypto-sources.mk
LOCAL_SDK_VERSION := 9
LOCAL_CFLAGS = -Wno-unused-parameter
# sha256-armv4.S does not compile with clang.
LOCAL_CLANG_ASFLAGS_arm += -no-integrated-as
LOCAL_CLANG_ASFLAGS_arm64 += -march=armv8-a+crypto
include $(LOCAL_PATH)/crypto-sources.mk
include $(BUILD_STATIC_LIBRARY)

# Target shared library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libcrypto
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/crypto-sources.mk
LOCAL_CFLAGS += -fvisibility=hidden -DBORINGSSL_SHARED_LIBRARY -DBORINGSSL_IMPLEMENTATION -Wno-unused-parameter

ifeq (,$(TARGET_BUILD_APPS))
# If we're building the platform (as opposed to unbundled) build, use clang and
# enable suitable sanitizers.
LOCAL_CLANG := true
LOCAL_SANITIZE := safe-stack unsigned-integer-overflow
LOCAL_CFLAGS += -fsanitize-blacklist=$(LOCAL_PATH)/sanitize-blacklist.txt
LOCAL_ADDITIONAL_DEPENDENCIES += $(LOCAL_PATH)/sanitize-blacklist.txt
else
# If we're building an unbundled build, don't try to use clang since it's not
# in the NDK yet. This can be removed when a clang version that is fast enough
# in the NDK.
LOCAL_SDK_VERSION := 9
endif

# sha256-armv4.S does not compile with clang.
LOCAL_CLANG_ASFLAGS_arm += -no-integrated-as
LOCAL_CLANG_ASFLAGS_arm64 += -march=armv8-a+crypto
include $(LOCAL_PATH)/crypto-sources.mk
include $(BUILD_SHARED_LIBRARY)

# Target static tool
include $(CLEAR_VARS)
LOCAL_CFLAGS += -Wall -Werror -std=c++0x
LOCAL_CPP_EXTENSION := cc
LOCAL_MODULE := bssl
LOCAL_MODULE_TAGS := optional
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/sources.mk
LOCAL_CFLAGS = -Wno-unused-parameter
LOCAL_SHARED_LIBRARIES=libcrypto libssl
include $(LOCAL_PATH)/sources.mk
LOCAL_SRC_FILES = $(tool_sources)
include $(BUILD_EXECUTABLE)

# Host static library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libcrypto_static
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/crypto-sources.mk
LOCAL_CFLAGS = -Wno-unused-parameter
# Windows and Macs both have problems with assembly files
ifneq ($(HOST_OS),linux)
LOCAL_CFLAGS += -DOPENSSL_NO_ASM
endif
include $(LOCAL_PATH)/crypto-sources.mk
include $(BUILD_HOST_STATIC_LIBRARY)

# Host shared library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libcrypto-host
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/include
LOCAL_MULTILIB := both
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/crypto-sources.mk
LOCAL_CFLAGS += -fvisibility=hidden -DBORINGSSL_SHARED_LIBRARY -DBORINGSSL_IMPLEMENTATION -Wno-unused-parameter
# Windows and Macs both have problems with assembly files
ifneq ($(HOST_OS),linux)
LOCAL_CFLAGS += -DOPENSSL_NO_ASM
endif
include $(LOCAL_PATH)/crypto-sources.mk
include $(BUILD_HOST_SHARED_LIBRARY)


## libssl

# Target static library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libssl_static
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/ssl-sources.mk
LOCAL_SDK_VERSION := 9
LOCAL_CFLAGS = -Wno-unused-parameter
include $(LOCAL_PATH)/ssl-sources.mk
include $(BUILD_STATIC_LIBRARY)

# Target shared library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libssl
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/ssl-sources.mk
LOCAL_CFLAGS += -fvisibility=hidden -DBORINGSSL_SHARED_LIBRARY -DBORINGSSL_IMPLEMENTATION -Wno-unused-parameter
LOCAL_SHARED_LIBRARIES=libcrypto

ifeq (,$(TARGET_BUILD_APPS))
# If we're building the platform (as opposed to unbundled) build, use clang and
# enable suitable sanitizers.
LOCAL_CLANG := true
LOCAL_SANITIZE := safe-stack unsigned-integer-overflow
LOCAL_CFLAGS += -fsanitize-blacklist=$(LOCAL_PATH)/sanitize-blacklist.txt
LOCAL_ADDITIONAL_DEPENDENCIES += $(LOCAL_PATH)/sanitize-blacklist.txt
else
# If we're building an unbundled build, don't try to use clang since it's not
# in the NDK yet. This can be removed when a clang version that is fast enough
# in the NDK.
LOCAL_SDK_VERSION := 9
endif

include $(LOCAL_PATH)/ssl-sources.mk
include $(BUILD_SHARED_LIBRARY)

# Host static library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libssl_static-host
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/ssl-sources.mk
LOCAL_CFLAGS = -Wno-unused-parameter
include $(LOCAL_PATH)/ssl-sources.mk
include $(BUILD_HOST_STATIC_LIBRARY)

# Host static tool (for linux only).
ifeq ($(HOST_OS), linux)
include $(CLEAR_VARS)
LOCAL_CFLAGS += -Wall -Werror -std=c++0x
LOCAL_CPP_EXTENSION := cc
LOCAL_MODULE := bssl
LOCAL_MODULE_TAGS := optional
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/sources.mk
LOCAL_CFLAGS = -Wno-unused-parameter
LOCAL_SHARED_LIBRARIES=libcrypto-host libssl-host
# Needed for clock_gettime.
LOCAL_LDFLAGS := -lrt
include $(LOCAL_PATH)/sources.mk
LOCAL_SRC_FILES = $(tool_sources)
include $(BUILD_HOST_EXECUTABLE)
endif  # HOST_OS == linux

# Host shared library
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libssl-host
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src/include
LOCAL_MULTILIB := both
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk $(LOCAL_PATH)/ssl-sources.mk
LOCAL_CFLAGS += -fvisibility=hidden -DBORINGSSL_SHARED_LIBRARY -DBORINGSSL_IMPLEMENTATION -Wno-unused-parameter
LOCAL_SHARED_LIBRARIES += libcrypto-host
include $(LOCAL_PATH)/ssl-sources.mk
include $(BUILD_HOST_SHARED_LIBRARY)
