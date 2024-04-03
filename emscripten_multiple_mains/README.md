**TL;DR:** in some cases, when accidentally defining more than one main function, this can crash the renderer process of an electron app (which is hard to debug). It would be ideal if emscripten could warn the user when multiple main functions are defined, instead of what appears to be a bug where it fails with "memory access out of bounds" (or on firefox, "RuntimeError: index out of bounds".

This repo is a (somewhat) minimal example of an issue I encountered:
* build Lua to a WASM static library (`libmy_lib.a`) with emscripten. Note that Lua defines a main function in `lua.c`.
* define an additional main function  (`test.c`), build a wasm executable (`my_exec.js` + `my_exec.wasm`) and link the static library created above (`libmy_lib.a`)

Note that when opening `index.html` with a browser, I get an error like this:

```
my_exec.wasm:0x8ba7c Uncaught (in promise) RuntimeError: memory access out of bounds
    at my_exec.wasm:0x8ba7c
    at my_exec.wasm:0x8b63e
    at my_exec.wasm:0x4cbf9
    at my_exec.wasm:0x4d0e8
    at my_exec.wasm:0x4d554
    at my_exec.wasm:0x4d628
    at my_exec.wasm:0x64737
    at invoke_vii (my_exec.js:4980:29)
    at my_exec.wasm:0x4a94f
    at my_exec.wasm:0x4e4d0
```

Though if you aren't using a main function (as I suspect many wasm web applications don't), I think this can simply be ignored.

However, when opening this page as an electron app, it crashes the rendering process:

`ELECTRON_ENABLE_LOGGING=1 electron .`

```
...
Renderer process crashed - see https://www.electronjs.org/docs/tutorial/application-debugging for potential debugging information.
```

Note that crashing the renderer process prevents dev tools from being accessible, so setting `ELECTRON_ENABLE_LOGGING=1` was the only way I could even figure out what went wrong.

## Other thoughts

I haven't been able to reproduce this issue by defining my own library, instead of using Lua. I'd be happy to dig in more, with some pointers.
