UBLUE_ROOT := /tmp/ublue-os
TARGET := ublue-os-wallpapers
RPMBUILD := $(UBLUE_ROOT)/rpmbuild

all: build-rpm

tarball:
	mkdir -p $(SOURCE_DIR) $(UBLUE_ROOT)/$(TARGET) $(RPMBUILD)/SOURCES
	cp -r ./src/* LICENSE $(UBLUE_ROOT)/$(TARGET)
	tar czf $(RPMBUILD)/SOURCES/$(TARGET).tar.gz -C $(UBLUE_ROOT)/$(TARGET) .
	
build-rpm: tarball
	cp ./*.spec $(UBLUE_ROOT)
	mkdir -p $(RPMBUILD)
	rpmbuild -ba \
    	--define '_topdir $(RPMBUILD)' \
    	--define '%_tmppath %{_topdir}/tmp' \
    	$(UBLUE_ROOT)/$(TARGET).spec

clean: $(SOURCE_DIR) $(RPMBUILD)
	rm -rf $^