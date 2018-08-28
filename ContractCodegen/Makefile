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
