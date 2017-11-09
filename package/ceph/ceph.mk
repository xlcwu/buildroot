################################################################################
#
# ceph
#
################################################################################

CEPH_VERSION = 10.2.6
CEPH_VERSION = 10.2.7
###CEPH_VERSION = 11.0.1
CEPH_SOURCE = ceph-$(CEPH_VERSION).tar.gz
CEPH_SITE = http://download.ceph.com/tarballs
#CEPH_SITE = $(call github,ceph,ceph,$(CEPH_VERSION))
#CEPH_SITE_METHOD = git
CEPH_LICENSE = LGPLv2.1+
CEPH_LICENSE_FILES = COPYING
CEPH_INSTALL_STAGING = YES
CEPH_AUTORECONF = YES
###CEPH_LIBTOOL_PATCH = YES

#CEPH_CONF_ENV += PYTHON_CFLAGS="-I$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)"
#CEPH_MAKE_OPTS += -j1
CEPH_MACHINE=$(BR2_ARCH)
# we're patching configure.in, but package cannot autoreconf with our version of
# autotools, so we have to do it manually instead of setting CEPH_AUTORECONF = YES
define CEPH_RUN_AUTOGEN
#	cd $(@D) && PATH=$(BR_PATH) ./do_autogen.sh
	cd $(@D) && $(SED) 's,PORTABLE=1,PORTABLE=1 MACHINE=$(CEPH_MACHINE) AR=$(TARGET_AR),' \
		$(@D)/src/kv/Makefile.am
	cd $(@D) && $(SED) 's,PORTABLE=1,PORTABLE=1 MACHINE=$(CEPH_MACHINE) AR=$(TARGET_AR),' \
		$(@D)/src/Makefile.in
	cd $(@D) && $(SED) 's,PYTHON_CFLAGS=`python-config,PYTHON_CFLAGS=`$(STAGING_DIR)/usr/bin/python2-config,' \
		$(@D)/configure.ac
	cd $(@D) && $(SED) 's,PYTHON_LDFLAGS=`python-config,PYTHON_LDFLAGS=`$(STAGING_DIR)/usr/bin/python2-config,' \
		$(@D)/configure.ac
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh -J -T

	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
                $(@D)/src/Makefile.in
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/ceph-detect-init/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/ceph-disk/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/pybind/cephfs/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/pybind/rados/Makefile.am
	cd $(@D) && $(SED) 's,install-layout=deb,prefix=/usr,' \
		$(@D)/src/pybind/rbd/Makefile.am
	cd $(@D) && $(SED) 's,ldl,ldl -lldap,' \
		$(@D)/src/rgw/Makefile.am
endef

CEPH_PRE_CONFIGURE_HOOKS += CEPH_RUN_AUTOGEN
HOST_CEPH_PRE_CONFIGURE_HOOKS += CEPH_RUN_AUTOGEN

CEPH_DEPENDENCIES += host-automake host-autoconf host-libtool \
			host-python-setuptools host-python-cython host-python-pip \
			libnspr icu snappy leveldb util-linux keyutils libnss \
			libatomic_ops xfsprogs btrfs-progs boost udev \
			libfcgi libcurl libedit expat glibmm libsigc python-setuptools
HOST_CEPH_DEPENDENCIES += host-automake host-autoconf host-libtool host-snappy

CEPH_INSTALL_TARGET_OPTS += -j1 DESTDIR=$(TARGET_DIR) install
CEPH_INSTALL_STAGING_OPTS += -j1 \
	DESTDIR=$(STAGING_DIR) install

#	prefix=$(STAGING_DIR)/usr \
	exec_prefix=$(STAGING_DIR)/usr \
	install install-lib

define CEPH_FIX_LIBTOOL_LA_LIBDIR
	$(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
		$(STAGING_DIR)/usr/lib/librados.la
	$(SED) "s,libdir=.*,libdir='$(STAGING_DIR)/usr/lib'," \
		$(STAGING_DIR)/usr/lib/librgw.la
endef

CEPH_POST_INSTALL_STAGING_HOOKS += CEPH_FIX_LIBTOOL_LA_LIBDIR

# We disable everything for now, because the dependency tree can become
# quite deep if we try to enable some features, and I have not tested that.
# We need at least one crypto lib, and the only one currently available in
# BR, that ceph can use, is libnss (in deps, above)
CEPH_CONF_OPTS =		\
	--enable-shared		\
	--disable-static	\
	--with-mon		\
	--with-rados		\
	--with-rbd		\
	--with-cephfs		\
	--with-radosgw		\
	--with-radosstriper	\
	--with-mon		\
	--with-osd		\
	--with-mds		\
	--with-evenfd		\
	--with-cython		\
	--with-nss		\
	--with-ocf		\
	--with-reentrant-strsignal \
	--with-thread-safe-res-query \
	--with-librocksdb-static \

ifeq ($(BR2_PACKAGE_LIBFUSE),y)
CEPH_DEPENDENCIES += libfuse
CEPH_CONF_OPTS += --with-fuse
else
CEPH_CONF_OPTS += --without-fuse
endif

ifeq ($(BR2_PACKAGE_LIBAIO),y)
CEPH_DEPENDENCIES += libaio
CEPH_CONF_OPTS += --with-libaio
else
CEPH_CONF_OPTS += --without-libaio
endif

###CEPH_CONF_OPTS += --without-tcmalloc
ifeq ($(BR2_PACKAGE_OPENLDAP),y)
CEPH_DEPENDENCIES += openldap
CEPH_CONF_OPTS += --with-radosgw
endif

ifeq ($(BR2_PACKAGE_CEPH_ALL),y)
CEPH_DEPENDENCIES += jemalloc
CEPH_CONF_OPTS += --with-jemalloc --without-tcmalloc
###CEPH_DEPENDENCIES += libpciaccess dpdk
###CEPH_CONF_OPTS += --with-spdk --without-"everything"
endif

define CEPH_FIX_PATH_INSTALL_SERVICE
	# Replace python description in header
	$(SED) "1,1s/.*/\#\!\/usr\/bin\/python/g" $(TARGET_DIR)/usr/bin/ceph-detect-init
	$(SED) "1,1s/.*/\#\!\/usr\/bin\/python/g" $(TARGET_DIR)/usr/sbin/ceph-disk
	$(SED) "1,1s/.*/\#\!\/usr\/bin\/python/g" $(TARGET_DIR)/usr/bin/ceph

	# Ceph init service
	$(INSTALL) -v -D -m 0644 $(@D)/src/init-ceph.in $(TARGET_DIR)/etc/init.d/ceph
	$(INSTALL) -v -D -m 0644 $(@D)/src/init-radosgw $(TARGET_DIR)/etc/init.d/radosgw
	$(INSTALL) -v -D -m 0644 $(@D)/src/init-rbdmap $(TARGET_DIR)/etc/init.d/rbdmap
endef

CEPH_POST_INSTALL_TARGET_HOOKS += CEPH_FIX_PATH_INSTALL_SERVICE

$(eval $(autotools-package))
$(eval $(host-autotools-package))
