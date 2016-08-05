default: install clean test

install:
	bundle install --path .bundle

clean:
	bundle clean

test:
	bundle exec rake test

.PHONY: test
