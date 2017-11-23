################################################################################
#
# gperf
#
################################################################################

GPERFTOOLS_VERSION = 2.4
GPERFTOOLS_VERSION = 2.5
GPERFTOOLS_VERSION = 2.6.1
GPERFTOOLS_SOURCE = gperftools-$(GPERFTOOLS_VERSION).tar.gz
GPERFTOOLS_SITE= $(call github,gperftools,gperftools,$(GPERFTOOLS_VERSION))
GPERFTOOLS_SITE = https://github.com/gperftools/gperftools/releases/download/gperftools-$(GPERFTOOLS_VERSION)
GPERFTOOLS_LICENSE = GPLv3+
GPERFTOOLS_LICENSE_FILES = COPYING
###GPERFTOOLS_CONF_OPTS += --enable-minimal
GPERFTOOLS_CFLAGS += -fPIC
GPERFTOOLS_CONF_OPTS += --enable-frame-pointers --enable-static --enable-shared
GPERFTOOLS_CONF_OPTS += --enable-libunwind
GPERFTOOLS_DEPENDENCIES += libunwind

define GPERFTOOLS_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

###GPERFTOOLS_PRE_CONFIGURE_HOOKS += GPERFTOOLS_RUN_AUTOGEN
###HOST_GPERFTOOLS_PRE_CONFIGURE_HOOKS += GPERFTOOLS_RUN_AUTOGEN

GPERFTOOLS_INSTALL_STAGING = YES

$(eval $(autotools-package))
$(eval $(host-autotools-package))
