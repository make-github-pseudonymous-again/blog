.PHONY: all deploy build public upload clean

all: build

deploy: clean build upload

build: public

serv:
	hugo server

public:
	hugo
	sed 's:<priority>0</priority>:<priority>1</priority>:g' public/sitemap.xml -i

upload:
	rsync -rhv --progress --delete public/ /var/www/blog.aurelienooms.be


clean:
	rm -rf public{,_html}
