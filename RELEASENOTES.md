## 0.29.1


refactor: update container callbacks to const API and add CMake interface propagation

* container key/value callbacks now use const-qualified signatures matching the new mulle-container API
* fix `removeObjectsInRange:` autoreleasing stale elements past the removed range
* `-UTF8String` for UTF-32 strings now autoreleases its backing allocation
* CMake OBJECT libraries inherit dependency usage requirements and propagate INTERFACE links
* API docs renamed from `TOC.md` to per-constituent `index.md`


## 0.29.0


feature: add MulleObjCFuture protocol conformance to NSDictionary and NSLocale

* NSDictionary SubclassesFuture category now conforms to MulleObjCFuture
* NSLocale Future category now conforms to MulleObjCFuture
