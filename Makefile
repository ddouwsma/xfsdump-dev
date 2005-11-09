#
# Copyright (c) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
#

TOPDIR = .
HAVE_BUILDDEFS = $(shell test -f $(TOPDIR)/include/builddefs && echo yes || echo no)

ifeq ($(HAVE_BUILDDEFS), yes)
include $(TOPDIR)/include/builddefs
endif

CONFIGURE = configure include/builddefs include/config.h
LSRCFILES = configure configure.in aclocal.m4 Makepkgs install-sh README VERSION

LDIRT = config.log .dep config.status config.cache confdefs.h conftest* \
	Logs/* built .census install.* install-dev.* *.gz

SUBDIRS = include librmt \
	common estimate fsr inventory invutil quota dump restore \
	m4 man doc po debian build

default: $(CONFIGURE)
ifeq ($(HAVE_BUILDDEFS), no)
	$(MAKE) -C . $@
else
	$(SUBDIRS_MAKERULE)
endif

ifeq ($(HAVE_BUILDDEFS), yes)
include $(BUILDRULES)
else
clean:	# if configure hasn't run, nothing to clean
endif

$(CONFIGURE):
	autoconf
	./configure \
		--prefix=/ \
		--exec-prefix=/ \
		--sbindir=/sbin \
		--bindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--includedir=/usr/include \
		--mandir=/usr/share/man \
		--datadir=/usr/share \
		$$LOCAL_CONFIGURE_OPTIONS
	touch .census

aclocal.m4::
	aclocal --acdir=$(TOPDIR)/m4 --output=$@

install: default
	$(SUBDIRS_MAKERULE)
	$(INSTALL) -m 755 -d $(PKG_DOC_DIR)
	$(INSTALL) -m 644 README $(PKG_DOC_DIR)

install-dev: default
	$(SUBDIRS_MAKERULE)

realclean distclean: clean
	rm -f $(LDIRT) $(CONFIGURE)
	rm -rf autom4te.cache Logs
