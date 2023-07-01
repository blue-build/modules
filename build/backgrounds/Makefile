UBLUE_ROOT := /tmp/ublue-os
TARGET := ublue-os-wallpapers
RPMBUILD := $(UBLUE_ROOT)/rpmbuild

all: build-rpm

clean:
	rm -rf $(RPMBUILD)

tarball: clean
	mkdir -p $(UBLUE_ROOT)/$(TARGET) $(RPMBUILD)/SOURCES xml
	cp -r src xml LICENSE $(UBLUE_ROOT)/$(TARGET)
	tar czf $(RPMBUILD)/SOURCES/$(TARGET).tar.gz -C $(UBLUE_ROOT)/$(TARGET) .
	
build-rpm: tarball
	cp ./*.spec $(UBLUE_ROOT)
	mkdir -p $(RPMBUILD)
	rpmbuild -ba \
    	--define '_topdir $(RPMBUILD)' \
    	--define '%_tmppath %{_topdir}/tmp' \
    	$(UBLUE_ROOT)/$(TARGET).spec

xml-files:
	mkdir -p xml
	sh gen-xml-files.sh
