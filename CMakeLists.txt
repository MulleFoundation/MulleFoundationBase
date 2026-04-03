#
# You rarely need to edit this file. To add or remove files in your
# project edit the "src" folders contents and run `mulle-sde reflect`
#
#
# A convenient way to add a new source file is:
#    mulle-sde add src/foo.m
#
cmake_minimum_required( VERSION 3.13)

project( MulleFoundationBase VERSION 0.27.0 LANGUAGES C)


set( MULLE_PROJECT_TYPE "Library")
set( PROJECT_VERSION  0.27.0)

### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include( Environment)

include( Files)

include( IDESupport OPTIONAL)


unset( SUB_PROJECT_NAMES)
file( GLOB SUB_PROJECT_PATHS src/MulleObjC*)

foreach( SUB_PROJECT_PATH ${SUB_PROJECT_PATHS})
   if( IS_DIRECTORY "${SUB_PROJECT_PATH}")
      get_filename_component( SUB_PROJECT_NAME "${SUB_PROJECT_PATH}" NAME)
      list( APPEND SUB_PROJECT_NAMES "${SUB_PROJECT_NAME}")
      message( STATUS "SUB_PROJECT_NAME = ${SUB_PROJECT_NAME}")
   endif()
endforeach()
set( SUB_PROJECT_NAMES ${SUB_PROJECT_NAMES} CACHE INTERNAL "sub-project names")


if( HEADER_PHASE)
   #
   # need to install like the embedded subprojects would
   #
   unset(REMAINING_PUBLIC_HEADERS)
   foreach( TMP_HEADER ${INSTALL_PUBLIC_HEADERS};${PUBLIC_GENERIC_HEADERS})
      get_filename_component( TMP_PROJECT_NAME "${TMP_HEADER}" DIRECTORY)
      get_filename_component( TMP_PROJECT_NAME "${TMP_PROJECT_NAME}" NAME)
      list( FIND SUB_PROJECT_NAMES "${TMP_PROJECT_NAME}" TMP_INDEX)
      # can't stay as a symlink, otherwise symlinks get installed which
      # fail, as they are relative
      file( REAL_PATH "${TMP_HEADER}" TMP_HEADER)
      if( NOT( "${TMP_INDEX}" EQUAL -1))
         install( FILES ${TMP_HEADER} DESTINATION "include/${TMP_PROJECT_NAME}")
      else()
         list( APPEND REMAINING_PUBLIC_HEADERS "${TMP_HEADER}")
      endif()
   endforeach()

   unset(REMAINING_PRIVATE_HEADERS)
   foreach( TMP_HEADER ${INSTALL_PRIVATE_HEADERS};${PRIVATE_GENERIC_HEADERS})
      get_filename_component( TMP_PROJECT_NAME "${TMP_HEADER}" DIRECTORY)
      get_filename_component( TMP_PROJECT_NAME "${TMP_PROJECT_NAME}" NAME)
      list( FIND SUB_PROJECT_NAMES "${TMP_PROJECT_NAME}" TMP_INDEX)
      # can't stay as a symlink, otherwise symlinks get installed which
      # fail, as they are relative
      file( REAL_PATH "${TMP_HEADER}" TMP_HEADER)
      if( NOT( "${TMP_INDEX}" EQUAL -1))
         install( FILES ${TMP_HEADER} DESTINATION "include/${TMP_PROJECT_NAME}")
      else()
         list( APPEND REMAINING_PRIVATE_HEADERS "${TMP_HEADER}")
      endif()
   endforeach()

   install( FILES ${REMAINING_PUBLIC_HEADERS}  DESTINATION "include/${PROJECT_NAME}")
   install( FILES ${REMAINING_PRIVATE_HEADERS} DESTINATION "include/${PROJECT_NAME}")
   install( FILES ${INSTALL_CMAKE_INCLUDES}          DESTINATION "include/${PROJECT_NAME}/cmake")

   # short cut out
   if( NOT COMPILE_PHASE AND NOT LINK_PHASE)
      return()
   endif()
endif()

if( LINK_PHASE)
   include( Dependencies OPTIONAL)
endif()

include( Library)

# use LIBRARY_COMPILE_TARGET for compiler options
target_compile_definitions( "${LIBRARY_COMPILE_TARGET}" PUBLIC)
target_compile_options( "${LIBRARY_COMPILE_TARGET}" PUBLIC)
# use LIBRARY_LINK_TARGET for linker options
if( LINK_PHASE)
   target_link_options( "${LIBRARY_LINK_TARGET}" PUBLIC)
endif()

include( InstallLibrary)

# Install TOC.md from constituent libraries
if( LINK_PHASE)
   foreach( SUB_PROJECT_NAME ${SUB_PROJECT_NAMES})
      set( SUB_ASSETS_TOC "${CMAKE_CURRENT_SOURCE_DIR}/src/${SUB_PROJECT_NAME}/TOC.md")
      if( EXISTS "${SUB_ASSETS_TOC}")
         message( STATUS "Installing TOC.md from ${SUB_PROJECT_NAME}")
         install( FILES "${SUB_ASSETS_TOC}"
                  PERMISSIONS OWNER_WRITE OWNER_READ
                              GROUP_READ
                              WORLD_READ
                  DESTINATION "share/${SUB_PROJECT_NAME}/dox")
      endif()
   endforeach()
endif()

if( LINK_PHASE)
   include( InstallCMakeInclude)
   include( InstallCMakePackage)
endif()


include( FinalOutput OPTIONAL)
