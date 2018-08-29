.PHONY : clean superclean build install dev

default: clean build

dev:
	swift package generate-xcodeproj

clean:
	swift package clean

superclean: clean
	rm -rf .build

build:
	swift build

install: clean
	swift build -c release
	mv .build/release/contractgen /usr/local/bin/contractgen
	mkdir -p /usr/local/share/contractgen
	cp -R templates /usr/local/share/contractgen/templates
	cp Rakefile /usr/local/share/contractgen/Rakefile
