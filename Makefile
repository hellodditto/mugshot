.PHONY: app run test clean

app:
	scripts/make-app.sh release

run: app
	open build/Mugshot.app

test:
	swift test

clean:
	rm -rf .build build
