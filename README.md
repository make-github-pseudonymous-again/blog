# Blog

## Dev

Clone with submodules

	git clone --recurse-submodules

If you forgot to recurse on cloning

	git submodule update --init --recursive

Update submodules.

	git submodule update --recursive

Downloads assets and static files

	make assets static

Serve blog locally

	make serv

## Build

	make build

## Deploy

On the production machine

	make deploy
