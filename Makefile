ROOT_DIR=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LOCAL_LIB?=/usr/local/lib
LUA_LIB=$(LOCAL_LIB)/lua

SOURCE=$(ROOT_DIR)/lua/toolbox
TARGET=$(LUA_LIB)/toolbox

all:
	clean install

test:
	busted "$(ROOT_DIR)/lua"

pre:
	sudo mkdir -p "$(LUA_LIB)"

clean:
	sudo unlink "$(TARGET)" &> /dev/null || true
	sudo rm -rf "$(TARGET)"

# install in "dev mode": source files are linked to target, so changes to files
# are reflected w/out re-installing
dev: pre
	sudo ln -s "$(SOURCE)" "$(TARGET)"

install: pre
	sudo cp -r "$(SOURCE)" "$(LUA_LIB)"
