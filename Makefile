.POSIX:
.SUFFIXES:

include config.mk

# flags for compiling
DWLCPPFLAGS = -I. -DWLR_USE_UNSTABLE -D_POSIX_C_SOURCE=200809L \
	-DVERSION=\"$(VERSION)\" $(XWAYLAND) $(FULLSCREEN_TEARING) $(FOREIGN_TOPLEVEL) $(WORKSPACES)
DWLDEVCFLAGS = -g -Wpedantic -Wall -Wextra -Wdeclaration-after-statement \
	-Wno-unused-parameter -Wshadow -Wunused-macros -Werror=strict-prototypes \
	-Werror=implicit -Werror=return-type -Werror=incompatible-pointer-types \
	-Wfloat-conversion -Wimplicit-fallthrough

# CFLAGS / LDFLAGS
PKGS      = wayland-server xkbcommon libinput $(XLIBS)
DWLCFLAGS = `$(PKG_CONFIG) --cflags $(PKGS)` $(WLR_INCS) $(DWLCPPFLAGS) $(DWLDEVCFLAGS) $(CFLAGS)
LDLIBS    = `$(PKG_CONFIG) --libs $(PKGS)` $(WLR_LIBS) -lm $(LIBS)

all: jtl
jtl: jtl.o
	$(CC) jtl.o $(DWLCFLAGS) $(LDFLAGS) $(LDLIBS) -o $@
jtl.o: jtl.c config.h config.mk cursor-shape-v1-protocol.h \
	pointer-constraints-unstable-v1-protocol.h wlr-layer-shell-unstable-v1-protocol.h \
	xdg-shell-protocol.h

# wayland-scanner is a tool which generates C headers and rigging for Wayland
# protocols, which are specified in XML. wlroots requires you to rig these up
# to your build system yourself and provide them in the include path.
WAYLAND_SCANNER   = `$(PKG_CONFIG) --variable=wayland_scanner wayland-scanner`
WAYLAND_PROTOCOLS = `$(PKG_CONFIG) --variable=pkgdatadir wayland-protocols`

cursor-shape-v1-protocol.h:
	$(WAYLAND_SCANNER) enum-header \
		$(WAYLAND_PROTOCOLS)/staging/cursor-shape/cursor-shape-v1.xml $@
pointer-constraints-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) enum-header \
		$(WAYLAND_PROTOCOLS)/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml $@
wlr-layer-shell-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) enum-header \
		protocols/wlr-layer-shell-unstable-v1.xml $@
xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

config.h:
	cp config.def.h $@
clean:
	rm -f jtl *.o *-protocol.h

dist: clean
	mkdir -p jtl-$(VERSION)
	cp -R LICENSE* Makefile CHANGELOG.md README.md config.def.h \
		config.mk protocols jtl.c jtl.desktop \
		jtl-$(VERSION)
	tar -caf jtl-$(VERSION).tar.gz jtl-$(VERSION)
	rm -rf jtl-$(VERSION)

install: jtl
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	rm -f $(DESTDIR)$(PREFIX)/bin/jtl
	cp -f jtl $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/jtl
	mkdir -p $(DESTDIR)$(DATADIR)/wayland-sessions
	cp -f jtl.desktop $(DESTDIR)$(DATADIR)/wayland-sessions/jtl.desktop
	chmod 644 $(DESTDIR)$(DATADIR)/wayland-sessions/jtl.desktop
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/jtl \
		$(DESTDIR)$(DATADIR)/wayland-sessions/jtl.desktop

.SUFFIXES: .c .o
.c.o:
	$(CC) $(CPPFLAGS) $(DWLCFLAGS) -o $@ -c $<
