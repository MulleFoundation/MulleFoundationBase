### 0.29.1




* container key/value callbacks now use const-qualified signatures matching the new mulle-container API (designated `describe`/`release`/`hash` casts)
* fix `removeObjectsInRange:` autoreleasing stale elements past the removed range
* `-UTF8String` for UTF-32 strings now autoreleases its backing allocation
* CMake OBJECT libraries inherit dependency usage requirements and propagate INTERFACE links, including whole-archive semantics for `add_subdirectory` consumers
* API docs renamed from `TOC.md` to per-constituent `index.md` and installed to `share/`<lib>`/dox/api/toc`
