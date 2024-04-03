#!/usr/bin/env bash

# Download Lua interpreter source code into third_party/lua
mkdir -p third_party/
cd third_party
git clone https://github.com/lua/lua.git
rm lua/onelua.c # this is a duplicate of all the source files, concatenated together
cd ../

mkdir -p out
mkdir -p out/obj

set -eux

FLAGS=-g
#FLAGS=--profiling-funcs

# It seems that none of emscripten/clang/gcc raise an error for this, at least on my system.
# But the others just seem to pick a main function and run it without issue, but
# browsers/electron have issues with the generated wasm/js.
CC=emcc
AR=emar
LIBS=

#CC=clang
#AR=llvm-ar
#LIBS=-lm

#CC=gcc
#AR=ar
#LIBS=-lm

# Build each Lua source file to an object
# Note that lua.c defines a main function.
for lua_src in third_party/lua/*.c; do
	obj_out_path=out/obj/$(basename ${lua_src%.*}.o)
	echo "Compiling $lua_src to object $obj_out_path"
	${CC} -v ${FLAGS} \
		'-Ithird_party/lua' \
		$lua_src \
		-c \
		-o $obj_out_path
done

# Build a static library out of the objects
echo "Building out/libmylib.a from objects in out/obj/*.o"
${AR} rcsv out/libmy_lib.a out/obj/*.o

# Build a *.js and *.wasm final output,
# linking with libmy_lib.a created earlier (which defines a main function), and
# including the additional main function defined in test.c.
echo "Building out/my_exec.js from:"
echo "    * out/libmylib.a (includes lua's main function) and"
echo "    * test.c (also defines a main function)"
${CC} ${FLAGS} \
	-v \
	-Wall \
	-Werror \
	-Wl,--undefined,error \
	-Wno-undef \
	test.c \
	-Lout/ \
	-lmy_lib \
	${LIBS} \
	-o out/my_exec.js

#	-Wl,--no-undefined \
