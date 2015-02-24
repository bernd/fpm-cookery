GEMSPEC=$(shell echo *.gemspec | awk '{print $$1}')
VERSION=$(shell awk -F\' '/VERSION =/ { print $$2 }' lib/fpm/cookery/version.rb)
NAME=$(shell awk -F\" '/s.name/ { print $$2 }' $(GEMSPEC))
GEM=$(NAME)-$(VERSION).gem

.PHONY: build
build: $(GEM)

.PHONY: test
test:
	rm -rf .yardoc
	rspec
	#sh notify-failure.sh rspec

.PHONY: testloop
testloop:
	while true; do \
		$(MAKE) test; \
		$(MAKE) wait-for-changes; \
	done

.PHONY: serve-coverage
serve-coverage:
	cd coverage; python -mSimpleHTTPServer

.PHONY: wait-for-changes
wait-for-changes:
	-inotifywait --exclude '\.swp' -e modify $$(find $(DIRS) -name '*.rb'; find $(DIRS) -type d)

.PHONY: package
package: | $(GEM)

.PHONY: gem
gem: $(GEM)

$(GEM):
	gem build $(GEMSPEC)

.PHONY: test-package
test-package: $(GEM)
	# Sometimes 'gem build' makes a faulty gem.
	gem unpack $(GEM)
	rm -rf ftw-$(VERSION)/

.PHONY: publish
publish: test-package
	gem push $(GEM)

.PHONY: install
install: $(GEM)
	gem install $(GEM)

.PHONY:
clean:
	rm -rf package-*/ *.rpm *.deb *.gz *.tar *.gem .yardoc/
