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
	rm -rf /usr/local/share/contractgen/templates
	cp -R templates /usr/local/share/contractgen/templates
	rm /usr/local/share/contractgen/Rakefile
	cp Rakefile /usr/local/share/contractgen/Rakefile
