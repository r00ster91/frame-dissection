# frame-dissection

This is about dissecting the content of what frame pointers point at, for research purposes.
The content of a frame is unspecified and platform-dependent so you should never rely on it.

A frame contains variable state as well as the suspend/resume state.

## Observations

In my specific runs on x86_64-linux.5.17.5...5.17.5-gnu.2.19 with Zig 0.10.0-dev.2398+b08d32ceb:

* The bytestream seems to be terminated by the same value as `@frameAddress`.
* The stack data seems to be laid out packed.
* There seem to be many addresses that are duplicated quite a lot.
