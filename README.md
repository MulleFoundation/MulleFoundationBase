# MulleFoundationBase

#### 🧱 MulleFoundationBase amalgamates Foundations projects

This is an almagamation of the MulleFoundation libraries that do not 
depend on platform specific code (below MulleObjCOSFoundation),
See the [constituting projects](#Constituents) for documentation, 
bug reports, pull requests.

The advantages of **MulleFoundationBase** are:

* compiles faster than almost a dozen individual projects
* you only need to link against one library file
* `#import` statements of the individual libraries can remain unchanged or can be simplified to `#import <MulleFoundationBase/MulleFoundationBase.h>`







## Documentation & Guides

* [API Summary](asset/dox/api/toc)
* [Coder Guide](asset/howto/coder/mulle-foundation-base)




## Constituents

Add another constituent to the amalgamation with:

``` bash
mulle-sde dependency add --amalgamated \
                         --fetchoptions "clibmode=copy" \
                         --address src/MulleObjCWhateverFoundation \
                         clib:MulleFoundation/MulleObjCWhateverFoundation
```

Then edit `MulleFoundationBase.h` and add the envelope header to the others.



| Constituent                                  | Description
|----------------------------------------------|-----------------------
| [MulleObjCArchiverFoundation](https://github.com/MulleFoundation/MulleObjCArchiverFoundation) | 🚪 NSCoding classes like NSArchiver/NSUnarchiver
| [MulleObjCContainerFoundation](https://github.com/MulleFoundation/MulleObjCContainerFoundation) | 🛍 Container classes like NSArray, NSSet, NSDictionary
| [MulleObjCKVCFoundation](https://github.com/MulleFoundation/MulleObjCKVCFoundation) | 🔑 Key-Value-Coding based on MulleObjCStandardFoundation
| [MulleObjCMathFoundation](https://github.com/MulleFoundation/MulleObjCMathFoundation) | 📈 NSNumber refines that use the math library
| [MulleObjCPlistFoundation](https://github.com/MulleFoundation/MulleObjCPlistFoundation) | 🏢 PropertyList parsing and printing
| [MulleObjCRegexFoundation](https://github.com/MulleFoundation/MulleObjCRegexFoundation) | 🫅 Search and replace with regular expressions
| [MulleObjCStandardFoundation](https://github.com/MulleFoundation/MulleObjCStandardFoundation) | 🚤 Objective-C classes based on the C standard library
| [MulleObjCTimeFoundation](https://github.com/MulleFoundation/MulleObjCTimeFoundation) | 💰 MulleObjCTimeFoundation provides time classes
| [MulleObjCUUIDFoundation](https://github.com/MulleFoundation/MulleObjCUUIDFoundation) | 🛂 MulleObjCUUIDFoundation provides NSUUID
| [MulleObjCUnicodeFoundation](https://github.com/MulleFoundation/MulleObjCUnicodeFoundation) | 🤓 Unicode 3.x.x support for mulle-objc
| [MulleObjCValueFoundation](https://github.com/MulleFoundation/MulleObjCValueFoundation) | 💶 Value classes NSNumber, NSString, NSDate, NSData


## Add

**This project is a component of the [MulleFoundation](//github.com/MulleFoundation/MulleFoundation) library.
As such you usually will *not* add or install it individually, unless you
specifically do not want to link against `MulleFoundation`.**


### Add as an individual component

Use [mulle-sde](//github.com/mulle-sde) to add MulleFoundationBase to your project:

``` sh
mulle-sde add github:MulleFoundation/MulleFoundationBase
```


## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleFoundationBase and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/MulleFoundation/MulleFoundationBase/archive/latest.tar.gz
```

### Legacy Installation

Install the requirements:

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleObjC](https://github.com/mulle-objc/MulleObjC)             | 💎 A collection of Objective-C root classes for mulle-objc
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Download the latest [tar](https://github.com/MulleFoundation/MulleFoundationBase/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/MulleFoundation/MulleFoundationBase/archive/refs/tags/latest.zip) archive and unpack it.

Install **MulleFoundationBase** into `/usr/local` with [cmake](https://cmake.org):

``` sh
PREFIX_DIR="/usr/local"
cmake -B build                               \
      -DMULLE_SDK_PATH="${PREFIX_DIR}"       \
      -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_DIR}"    \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```

## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  


