## 0.30.0







* document the renamed/expanded constituent set (regex patterns, ordered sets, scanners, formatters, undo manager)
* correct API signatures to match headers verbatim, including class clusters and `SubclassesFuture` primitives
* note platform-independent scope, 2001 date epoch, 32-bit `unichar`, and strict UUID v4/variant 2
* expand regex docs with `MulleObjCPattern` all-match APIs, `NSScanner(Regex)` and the pattern-driven tokenizer
* add KVC container mapping and collection-operator coverage, plus updated performance and pitfall guidance



* document the renamed/expanded constituent set (regex patterns, ordered sets, scanners, formatters, undo manager)
* correct API signatures to match headers verbatim, including class clusters and `SubclassesFuture` primitives
* note platform-independent scope, 2001 date epoch, 32-bit `unichar`, and strict UUID v4/variant 2
* expand regex docs with `MulleObjCPattern` all-match APIs, `NSScanner(Regex)` and the pattern-driven tokenizer
* add KVC container mapping and collection-operator coverage, plus updated performance and pitfall guidance



feature: add ordered set, regex/tokenizer and locale support

* new NSOrderedSet and NSMutableOrderedSet classes, plus their concrete and placeholder implementations
* new regex and tokenizer classes in MulleObjCRegexFoundation: MulleObjCPattern, MulleObjCToken, MulleObjCTokenSet, MulleObjCTokenRule, MulleObjCTokenizer and NSScanner+Regex
* **BREAKING** remove MulleObjCArchiverFoundation, dropping NSArchiver/NSUnarchiver, NSCoder and NSKeyedArchiver/NSKeyedUnarchiver
* NSLocale greatly expanded with locale data, formatting and lookup behaviour
* rename the mulle-objc-list dependency to mulle-objc-tools


### 0.29.1




* container key/value callbacks now use const-qualified signatures matching the new mulle-container API (designated `describe`/`release`/`hash` casts)
* fix `removeObjectsInRange:` autoreleasing stale elements past the removed range
* `-UTF8String` for UTF-32 strings now autoreleases its backing allocation
* CMake OBJECT libraries inherit dependency usage requirements and propagate INTERFACE links, including whole-archive semantics for `add_subdirectory` consumers
* API docs renamed from `TOC.md` to per-constituent `index.md` and installed to `share/`<lib>`/dox/api/toc`
