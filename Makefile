PREFIX ?= /usr
QMLDIR ?= $(PREFIX)/lib/qt6/qml
DEST = $(DESTDIR)$(QMLDIR)/Twilight/Compositor

install:
	install -d $(DEST)
	cp -r Twilight/Compositor/. $(DEST)

uninstall:
	rm -rf $(DEST)

.PHONY: install uninstall
