/*
 *   This file will be regenerated by `mulle-project-versioncheck`.
 *   Any edits will be lost.
 */
#ifndef mulle_objc_value_foundation_versioncheck_h__
#define mulle_objc_value_foundation_versioncheck_h__

#if defined( MULLE__BUFFER_VERSION)
# ifndef MULLE__BUFFER_VERSION_MIN
#  define MULLE__BUFFER_VERSION_MIN  ((3 << 20) | (5 << 8) | 0)
# endif
# ifndef MULLE__BUFFER_VERSION_MAX
#  define MULLE__BUFFER_VERSION_MAX  ((4 << 20) | (0 << 8) | 0)
# endif
# if MULLE__BUFFER_VERSION < MULLE__BUFFER_VERSION_MIN
#  error "mulle-buffer is too old"
# endif
# if MULLE__BUFFER_VERSION >= MULLE__BUFFER_VERSION_MAX
#  error "mulle-buffer is too new"
# endif
#endif

#if defined( MULLE_OBJC_VERSION)
# ifndef MULLE_OBJC_VERSION_MIN
#  define MULLE_OBJC_VERSION_MIN  ((0 << 20) | (23 << 8) | 0)
# endif
# ifndef MULLE_OBJC_VERSION_MAX
#  define MULLE_OBJC_VERSION_MAX  ((0 << 20) | (24 << 8) | 0)
# endif
# if MULLE_OBJC_VERSION < MULLE_OBJC_VERSION_MIN
#  error "MulleObjC is too old"
# endif
# if MULLE_OBJC_VERSION >= MULLE_OBJC_VERSION_MAX
#  error "MulleObjC is too new"
# endif
#endif

#if defined( MULLE__UTF_VERSION)
# ifndef MULLE__UTF_VERSION_MIN
#  define MULLE__UTF_VERSION_MIN  ((4 << 20) | (0 << 8) | 0)
# endif
# ifndef MULLE__UTF_VERSION_MAX
#  define MULLE__UTF_VERSION_MAX  ((5 << 20) | (0 << 8) | 0)
# endif
# if MULLE__UTF_VERSION < MULLE__UTF_VERSION_MIN
#  error "mulle-utf is too old"
# endif
# if MULLE__UTF_VERSION >= MULLE__UTF_VERSION_MAX
#  error "mulle-utf is too new"
# endif
#endif

#endif