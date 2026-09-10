
CFLAGS = -Os -march=native -mtune=native -pipe \
         -fno-inline -fno-inline-functions \
         -fno-reorder-blocks -fno-unroll-loops \
         -fno-plt -fomit-frame-pointer \
         -fstack-protector-strong -D_FORTIFY_SOURCE=2 \
         -ffunction-sections -fdata-sections

LDFLAGS = -Wl,--as-needed,--gc-sections
_VERSION = jtl-v.1.4
VERSION  = `git describe --tags --dirty 2>/dev/null || echo $(_VERSION)`

PKG_CONFIG = pkg-config

# paths
PREFIX = /usr/local
MANDIR = $(PREFIX)/share/man
DATADIR = $(PREFIX)/share

WLR_INCS = `$(PKG_CONFIG) --cflags wlroots-0.21`
WLR_LIBS = `$(PKG_CONFIG) --libs wlroots-0.21`

# Allow using an alternative wlroots installation
# This has to have all the includes required by wlroots, e.g:
# Assuming wlroots git repo is "${PWD}/wlroots" and you only ran "meson setup build && ninja -C build"
#WLR_INCS = -I/usr/include/pixman-1 -I/usr/include/elogind -I/usr/include/libdrm \
#	-I$(PWD)/wlroots/include
# Set -rpath to avoid using the wrong library.
#WLR_LIBS = -Wl,-rpath,$(PWD)/wlroots/build -L$(PWD)/wlroots/build -lwlroots-0.19

# Assuming you ran "meson setup --prefix ${PWD}/0.19 build && ninja -C build install"
#WLR_INCS = -I/usr/include/pixman-1 -I/usr/include/elogind -I/usr/include/libdrm \
#	-I$(PWD)/wlroots/0.19/include/wlroots-0.19
#WLR_LIBS = -Wl,-rpath,$(PWD)/wlroots/0.19/lib64 -L$(PWD)/wlroots/0.19/lib64 -lwlroots-0.19

#XWAYLAND =
#XLIBS =
# Uncomment to build XWayland support
XWAYLAND = -DXWAYLAND
XLIBS = xcb xcb-icccm

# Uncomment to enable fullscreen tearing support (Mod+O enable, Mod+P disable)
FULLSCREEN_TEARING = -DFULLSCREEN_TEARING

# Uncomment to enable foreign toplevel management (for waybar, nwg-bar, etc.)
FOREIGN_TOPLEVEL = -DFOREIGN_TOPLEVEL

# Uncomment to enable the workspaces (ext-workspace-v1) protocol (for jtlab tray workspace popup)
WORKSPACES = -DWORKSPACES

# dwl itself only uses C99 features, but wlroots' headers use anonymous unions (C11).
# To avoid warnings about them, we do not use -std=c99 and instead of using the
# gmake default 'CC=c99', we use cc.
CC = cc
