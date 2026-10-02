//
//  MulleObjCPattern-Private.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"

#import "NSString+Regex.h"

// declared here, so that this header does not expose mulle-regex
struct mulle_utf32regex;


//
// The pattern conversion is shared with NSString( Regex), so that both
// interpret a pattern string in exactly the same way. This is the same
// machinery that adds `^` and `$` for the anchoring options and that
// rewrites wildcard and sed syntax.
//
// MulleObjCPatternSize returns the number of unichar needed for the
// conversion buffer. MulleObjCPatternConvert fills it, NUL terminates it
// and returns a pointer past the converted pattern.
//
MULLE_OBJC_REGEX_FOUNDATION_GLOBAL
size_t     MulleObjCPatternSize( NSString *pattern,
                                 MulleObjCPatternOptions options);

MULLE_OBJC_REGEX_FOUNDATION_GLOBAL
unichar   *MulleObjCPatternConvert( NSString *pattern,
                                    unichar *copy,
                                    MulleObjCPatternOptions options);

//
// Compiles a pattern, that MulleObjCPatternConvert has produced. A pattern
// option, that selects another pattern language, is mapped onto the
// mulle-regex compile options here, so that conversion and compilation of a
// pattern always agree.
//
// MulleObjCPatternCompile returns NULL, if the pattern is malformed.
//
MULLE_OBJC_REGEX_FOUNDATION_GLOBAL
struct mulle_utf32regex   *MulleObjCPatternCompile( unichar *characters,
                                                    MulleObjCPatternOptions options);
