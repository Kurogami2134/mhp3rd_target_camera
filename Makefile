ARMIPS_URL := https://github.com/Kingcom/armips.git
MODIO_URL := https://github.com/Kurogami2134/modio.git

BUILD_DIR := build
INSTALL_DIR := /usr/local/bin

CHEAT_FILE := CHEAT.TXT

.PHONY: deps, armips, modio

$(CHEAT_FILE):
	mkdir -p bin
	armips src/src.asm
	python3 gencwcheat.py

modio:
	if [ ! -d modio ]; then \
		git clone $(MODIO_URL); \
	fi
	mv modio/ModIO/cwcheatio.py ./

armips:
	if [ ! -d armips ]; then \
		git clone --recursive $(ARMIPS_URL); \
	fi

	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake -DCMAKE_BUILD_TYPE=Release ../armips
	$(MAKE) -C $(BUILD_DIR)

	install -Dm755 $(BUILD_DIR)/armips $(INSTALL_DIR)/armips

deps: armips modio

clean:
	rm -rf armips
	rm -rf modio
	rm -rf build
	rm -rf cwcheatio*
	rm -rf *.txt *.TXT
	rm -rf bin
