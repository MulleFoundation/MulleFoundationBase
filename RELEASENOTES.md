## 0.28.0







feature: add amalgamated MulleObjC foundation sources into MulleFoundationBase

* Amalgamate core MulleObjC foundation modules (Container, Value, Standard, Plist, Archiver, Time, UUID, Regex, Math, KVC, etc.) into MulleFoundationBase so consumers can link/import a single library to get common Objective-C foundation APIs.
* Update developer guidance and build plumbing so the amalgamated sources build as one library (AGENTS.md updates + CMake reflect/share files adjusted).
