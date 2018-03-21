cmake_minimum_required( VERSION 3.1 )

set( source_root "${CMAKE_CURRENT_SOURCE_DIR}/../.." )

execute_process(
  COMMAND iscool-shell-config --cmake-modules
  OUTPUT_VARIABLE iscool_cmake_modules
  )

if( NOT iscool_cmake_modules )
  message( FATAL_ERROR "Could not find directory for IsCool's CMake modules." )
endif()

string( STRIP "${iscool_cmake_modules}" iscool_cmake_modules )

set( CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${iscool_cmake_modules}
  )

include( uninstall )

install(
  DIRECTORY ${source_root}/prefix/
  DESTINATION .
  USE_SOURCE_PERMISSIONS
  )
