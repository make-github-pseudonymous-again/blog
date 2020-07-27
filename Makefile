.PHONY: all build assets static upload deploy serv clean nuke
.SECONDARY:

HUGO := hugo --gc
#KATEX_VERSION := 0.10.2
URL_MATERIALIZE_ZIP := https://github.com/Dogfalo/materialize/releases/download/1.0.0/materialize-src-v1.0.0.zip
URL_MATERIALICONS_CSS := https://fonts.googleapis.com/icon?family=Material+Icons
URL_LUNR_JS := https://unpkg.com/lunr/lunr.min.js
URL_LODASH_JS := https://raw.githubusercontent.com/lodash/lodash/4.17.11-npm/lodash.min.js
#URL_KATEX := https://cdn.jsdelivr.net/npm/katex@$(KATEX_VERSION)
#URL_KATEX_CSS := $(URL_KATEX)/dist/katex.min.css
#URL_KATEX_JS := $(URL_KATEX)/dist/katex.min.js
#URL_KATEX_AUTO_RENDER_JS := $(URL_KATEX)/dist/contrib/auto-render.min.js
ASSETS := assets/vendor/materialize-src assets/vendor/material-icons.css
#assets/katex.min.css assets/katex.min.js assets/katex-auto-render.min.js
STATIC := static/vendor/lunr.min.js static/vendor/lodash.min.js

all: build

deploy: clean build upload

build: assets static
	$(HUGO)

serv: clean assets static
	$(HUGO) server

assets: $(ASSETS)

static: $(STATIC)

upload:
	rsync -rhv --progress --delete public/ /var/www/blog.aurelienooms.be

assets/vendor/materialize-src: static/vendor/materialize.zip
	mkdir -p $(dir $@)
	unzip $< -d $(dir $@)

static/vendor/materialize.zip:
	mkdir -p $(dir $@)
	wget -O $@ $(URL_MATERIALIZE_ZIP)

assets/vendor/material-icons.css:
	mkdir -p $(dir $@)
	wget -O $@ $(URL_MATERIALICONS_CSS)

static/vendor/lunr.min.js:
	mkdir -p $(dir $@)
	wget -O $@ $(URL_LUNR_JS)

static/vendor/lodash.min.js:
	mkdir -p $(dir $@)
	wget -O $@ $(URL_LODASH_JS)

#assets/katex.min.css:
	#mkdir -p $(dir $@)
	#wget -O $@ $(URL_KATEX_CSS)

#assets/katex.min.js:
	#mkdir -p $(dir $@)
	#wget -O $@ $(URL_KATEX_JS)

#assets/katex-auto-render.min.js:
	#mkdir -p $(dir $@)
	#wget -O $@ $(URL_KATEX_AUTO_RENDER_JS)

clean:
	rm -rf resources public

nuke: clean
	rm -rf $(ASSETS) $(STATIC)
