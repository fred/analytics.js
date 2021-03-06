
TEST = http://localhost:4200
COMPONENT = node_modules/component/bin/component
UGLIFY = node_modules/uglify-js/bin/uglifyjs
PHANTOM = node_modules/.bin/mocha-phantomjs --setting web-security=false --setting local-to-remote-url-access=true


# Default
default: build/build.js


# Reals
analytics.js: node_modules components lib/*.js lib/**/*.js
	@$(COMPONENT) build --standalone analytics --out . --name analytics
	@$(UGLIFY) analytics.js --output analytics.min.js

build/build.js: node_modules components lib/*.js lib/**/*.js
	@$(COMPONENT) build --dev

components: component.json
	@$(COMPONENT) install --dev

node_modules: package.json
	@npm install


# Phonies
clean:
	@rm -rf components build node_modules

kill:
	@kill -9 `cat test/server/.pid.txt`
	@rm test/server/.pid.txt

install: components node_modules

server: node_modules
	@node test/server/index.js &

release: test-release

test: node_modules build/build.js server
	@sleep 1
	-@$(PHANTOM) $(TEST)/core
	-@$(PHANTOM) $(TEST)/integrations
	@make kill

test-browser: node_modules build/build.js server
	@sleep 1
	@open $(TEST)/core
	@open $(TEST)/integrations

test-release: node_modules analytics.js build/build.js server
	@sleep 1
	-@$(PHANTOM) $(TEST)/all
	@make kill

.PHONY: clean kill install release server test test-browser