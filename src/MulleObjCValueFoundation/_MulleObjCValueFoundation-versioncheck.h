/*
 *   This file will be regenerated by `mulle-project-versioncheck`.
 *   Any edits will be lost.
 */
#if defined( MULLE_BUFFER_VERSION)
# if MULLE_BUFFER_VERSION < ((3 << 20) | (3 << 8) | 0)
#  error "mulle-buffer is too old"
# endif
# if MULLE_BUFFER_VERSION >= ((4 << 20) | (0 << 8) | 0)
#  error "mulle-buffer is too new"
# endif
#endif

#if defined( MULLE_OBJC_VERSION)
# if MULLE_OBJC_VERSION < ((0 << 20) | (22 << 8) | 1)
#  error "MulleObjC is too old"
# endif
# if MULLE_OBJC_VERSION >= ((0 << 20) | (23 << 8) | 0)
#  error "MulleObjC is too new"
# endif
#endif

#if defined( MULLE_UTF_VERSION)
# if MULLE_UTF_VERSION < ((3 << 20) | (1 << 8) | 3)
#  error "mulle-utf is too old"
# endif
# if MULLE_UTF_VERSION >= ((4 << 20) | (0 << 8) | 0)
#  error "mulle-utf is too new"
# endif
#endif
