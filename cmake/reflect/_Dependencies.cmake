# This file will be regenerated by `mulle-sourcetree-to-cmake` via
# `mulle-sde reflect` and any edits will be lost.
#
# This file will be included by cmake/share/Files.cmake
#
# Disable generation of this file with:
#
# mulle-sde environment set MULLE_SOURCETREE_TO_CMAKE_DEPENDENCIES_FILE DISABLE
#
if( MULLE_TRACE_INCLUDE)
   message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# Generated from sourcetree: BCC7C22B-9D18-4423-AA8B-67BF9802C953;MulleObjC;no-singlephase;
# Disable with : `mulle-sourcetree mark MulleObjC no-link`
# Disable for this platform: `mulle-sourcetree mark MulleObjC no-cmake-platform-${MULLE_UNAME}`
# Disable for a sdk: `mulle-sourcetree mark MulleObjC no-cmake-sdk-<name>`
#
if( NOT MULLE_OBJC_LIBRARY)
   if( DEPENDENCY_IGNORE_SYSTEM_LIBARIES)
      find_library( MULLE_OBJC_LIBRARY NAMES
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjC${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjC${CMAKE_STATIC_LIBRARY_SUFFIX}
         MulleObjC
         NO_CMAKE_SYSTEM_PATH NO_SYSTEM_ENVIRONMENT_PATH
      )
   else()
      find_library( MULLE_OBJC_LIBRARY NAMES
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjC${CMAKE_DEBUG_POSTFIX}${CMAKE_STATIC_LIBRARY_SUFFIX}
         ${CMAKE_STATIC_LIBRARY_PREFIX}MulleObjC${CMAKE_STATIC_LIBRARY_SUFFIX}
         MulleObjC
      )
   endif()
   message( STATUS "MULLE_OBJC_LIBRARY is ${MULLE_OBJC_LIBRARY}")
   #
   # The order looks ascending, but due to the way this file is read
   # it ends up being descending, which is what we need.
   #
   if( MULLE_OBJC_LIBRARY)
      #
      # Add MULLE_OBJC_LIBRARY to ALL_LOAD_DEPENDENCY_LIBRARIES list.
      # Disable with: `mulle-sourcetree mark MulleObjC no-cmake-add`
      #
      list( APPEND ALL_LOAD_DEPENDENCY_LIBRARIES ${MULLE_OBJC_LIBRARY})
      #
      # Inherit information from dependency.
      # Encompasses: no-cmake-searchpath,no-cmake-dependency,no-cmake-loader
      # Disable with: `mulle-sourcetree mark MulleObjC no-cmake-inherit`
      #
      # temporarily expand CMAKE_MODULE_PATH
      get_filename_component( _TMP_MULLE_OBJC_ROOT "${MULLE_OBJC_LIBRARY}" DIRECTORY)
      get_filename_component( _TMP_MULLE_OBJC_ROOT "${_TMP_MULLE_OBJC_ROOT}" DIRECTORY)
      #
      #
      # Search for "Definitions.cmake" and "DependenciesAndLibraries.cmake" to include.
      # Disable with: `mulle-sourcetree mark MulleObjC no-cmake-dependency`
      #
      foreach( _TMP_MULLE_OBJC_NAME "MulleObjC")
         set( _TMP_MULLE_OBJC_DIR "${_TMP_MULLE_OBJC_ROOT}/include/${_TMP_MULLE_OBJC_NAME}/cmake")
         # use explicit path to avoid "surprises"
         if( IS_DIRECTORY "${_TMP_MULLE_OBJC_DIR}")
            list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_OBJC_DIR}")
            #
            include( "${_TMP_MULLE_OBJC_DIR}/DependenciesAndLibraries.cmake" OPTIONAL)
            #
            list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_OBJC_DIR}")
            #
            unset( MULLE_OBJC_DEFINITIONS)
            include( "${_TMP_MULLE_OBJC_DIR}/Definitions.cmake" OPTIONAL)
            list( APPEND INHERITED_DEFINITIONS ${MULLE_OBJC_DEFINITIONS})
            break()
         else()
            message( STATUS "${_TMP_MULLE_OBJC_DIR} not found")
         endif()
      endforeach()
      #
      # Search for "MulleObjCLoader+<name>.h" in include directory.
      # Disable with: `mulle-sourcetree mark MulleObjC no-cmake-loader`
      #
      if( NOT NO_INHERIT_OBJC_LOADERS)
         foreach( _TMP_MULLE_OBJC_NAME "MulleObjC")
            set( _TMP_MULLE_OBJC_FILE "${_TMP_MULLE_OBJC_ROOT}/include/${_TMP_MULLE_OBJC_NAME}/MulleObjCLoader+${_TMP_MULLE_OBJC_NAME}.h")
            if( EXISTS "${_TMP_MULLE_OBJC_FILE}")
               list( APPEND INHERITED_OBJC_LOADERS ${_TMP_MULLE_OBJC_FILE})
               break()
            endif()
         endforeach()
      endif()
   else()
      # Disable with: `mulle-sourcetree mark MulleObjC no-require-link`
      message( FATAL_ERROR "MULLE_OBJC_LIBRARY was not found")
   endif()
endif()