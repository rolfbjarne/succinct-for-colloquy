INSTALLDIR="$(HOME)/Library/Application Support/Colloquy/Styles"

install:
	mkdir -p $(INSTALLDIR)
	cp -R Succinct.colloquyStyle $(INSTALLDIR)