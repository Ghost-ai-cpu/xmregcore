#------------------------------------------------------------------------------
# CMake helper for the majority of the cpp-ethereum modules.
#
# This module defines
#     Worktips_XXX_LIBRARIES, the libraries needed to use ethereum.
#     Worktips_FOUND, If false, do not try to use ethereum.
#
# File addetped from cpp-ethereum
#
# The documentation for cpp-ethereum is hosted at http://cpp-ethereum.org
#
# ------------------------------------------------------------------------------
# This file is part of cpp-ethereum.
#
# cpp-ethereum is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cpp-ethereum is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cpp-ethereum.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2014-2016 cpp-ethereum contributors.
#------------------------------------------------------------------------------


if (NOT WORKTIPS_DIR)
    set(WORKTIPS_DIR ~/worktips)
endif()

message(STATUS WORKTIPS_DIR ": ${WORKTIPS_DIR}")

set(WORKTIPS_SOURCE_DIR ${WORKTIPS_DIR}
        CACHE PATH "Path to the root directory for Worktips")

# set location of worktips build tree
set(WORKTIPS_BUILD_DIR ${WORKTIPS_SOURCE_DIR}/build/release/
        CACHE PATH "Path to the build directory for Worktips")


if (NOT EXISTS ${WORKTIPS_BUILD_DIR})
    # try different location
    message(STATUS "Trying different folder for worktips libraries")
    set(WORKTIPS_BUILD_DIR ${WORKTIPS_SOURCE_DIR}/build/Linux/master/release/
        CACHE PATH "Path to the build directory for Worktips" FORCE)
endif()


if (NOT EXISTS ${WORKTIPS_BUILD_DIR})   
  message(FATAL_ERROR "Worktips libraries not found in: ${WORKTIPS_BUILD_DIR}")
endif()

MESSAGE(STATUS "Looking for libunbound") # FindUnbound.cmake from worktips repo


set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${WORKTIPS_BUILD_DIR}"
        CACHE PATH "Add Worktips directory for library searching")


set(LIBS common
		blocks
		cryptonote_basic
		cryptonote_core
		cryptonote_protocol
		daemonizer
		mnemonics
		epee
		lmdb
		device
		blockchain_db
		ringct
		wallet
		cncrypto
		easylogging
		version
		checkpoints
		ringct_basic)

set(Xmr_INCLUDE_DIRS "${CPP_WORKTIPS_DIR}")

# if the project is a subset of main cpp-ethereum project
# use same pattern for variables as Boost uses

set(Worktips_LIBRARIES "")

foreach (l ${LIBS})

	string(TOUPPER ${l} L)

	find_library(Xmr_${L}_LIBRARY
			NAMES ${l}
			PATHS ${CMAKE_LIBRARY_PATH}
                        PATH_SUFFIXES  "/src/${l}"
                                        "/src/"
                                        "/external/db_drivers/lib${l}"
                                        "/lib"
                                        "/src/crypto"
                                        "/contrib/epee/src"
                                        "/external/easylogging++/"
                                        "/src/crypto/wallet"
                                        "/contrib/epee/src"
                                        "/src/crypto/wallet"
                                        "/src/cryptonote_basic"
                                        "/external/easylogging++/"
                                        "external/miniupnp/miniupnpc"
                                        "/src/ringct/"
                                        "/external/${l}"
			NO_DEFAULT_PATH
			)

	set(Xmr_${L}_LIBRARIES ${Xmr_${L}_LIBRARY})

	message(STATUS FindWorktips " Xmr_${L}_LIBRARIES ${Xmr_${L}_LIBRARY}")

    add_library(${l} STATIC IMPORTED)
	set_property(TARGET ${l} PROPERTY IMPORTED_LOCATION ${Xmr_${L}_LIBRARIES})

    set(Worktips_LIBRARIES ${Worktips_LIBRARIES} ${l} CACHE INTERNAL "Worktips LIBRARIES")

endforeach()


FIND_PATH(UNBOUND_INCLUDE_DIR
  NAMES unbound.h
  PATH_SUFFIXES include/ include/unbound/
  PATHS "${PROJECT_SOURCE_DIR}"
  ${UNBOUND_ROOT}
  $ENV{UNBOUND_ROOT}
  /usr/local/
  /usr/
)

find_library (UNBOUND_LIBRARY unbound)
if (WIN32 OR (${UNBOUND_LIBRARY} STREQUAL "UNBOUND_LIBRARY-NOTFOUND"))
    add_library(unbound STATIC IMPORTED)
    set_property(TARGET unbound PROPERTY IMPORTED_LOCATION ${WORKTIPS_BUILD_DIR}/external/unbound/libunbound.a)
endif()

message("Xmr_WALLET-CRYPTO_LIBRARIES ${Xmr_WALLET-CRYPTO_LIBRARIES}")

if("${Xmr_WALLET-CRYPTO_LIBRARIES}" STREQUAL "Xmr_WALLET-CRYPTO_LIBRARY-NOTFOUND")
  set(WALLET_CRYPTO "")
else()
  set(WALLET_CRYPTO ${Xmr_WALLET-CRYPTO_LIBRARIES})
endif()



message("WALLET_CRYPTO ${WALLET_CRYPTO}")



message("FOUND Worktips_LIBRARIES: ${Worktips_LIBRARIES}")

message(STATUS ${WORKTIPS_SOURCE_DIR}/build)

#macro(target_include_worktips_directories target_name)

    #target_include_directories(${target_name}
        #PRIVATE
        #${WORKTIPS_SOURCE_DIR}/src
        #${WORKTIPS_SOURCE_DIR}/external
        #${WORKTIPS_SOURCE_DIR}/build
        #${WORKTIPS_SOURCE_DIR}/external/easylogging++
        #${WORKTIPS_SOURCE_DIR}/contrib/epee/include
        #${WORKTIPS_SOURCE_DIR}/external/db_drivers/liblmdb)

#endmacro(target_include_worktips_directories)


add_library(Worktips::Worktips INTERFACE IMPORTED GLOBAL)

# Requires to new cmake
#target_include_directories(Worktips::Worktips INTERFACE        
    #${WORKTIPS_SOURCE_DIR}/src
    #${WORKTIPS_SOURCE_DIR}/external
    #${WORKTIPS_SOURCE_DIR}/build
    #${WORKTIPS_SOURCE_DIR}/external/easylogging++
    #${WORKTIPS_SOURCE_DIR}/contrib/epee/include
    #${WORKTIPS_SOURCE_DIR}/external/db_drivers/liblmdb)

set_target_properties(Worktips::Worktips PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES 
            "${WORKTIPS_SOURCE_DIR}/src;${WORKTIPS_SOURCE_DIR}/external;${WORKTIPS_SOURCE_DIR}/src/crypto;${WORKTIPS_SOURCE_DIR}/src/wallet;${WORKTIPS_SOURCE_DIR}/build;${WORKTIPS_SOURCE_DIR}/external/easylogging++;${WORKTIPS_SOURCE_DIR}/contrib/epee/include;${WORKTIPS_SOURCE_DIR}/external/db_drivers/liblmdb;${WORKTIPS_SOURCE_DIR}/external/worktips-mq/worktipsmq")


target_link_libraries(Worktips::Worktips INTERFACE
    ${Worktips_LIBRARIES} ${WALLET_CRYPTO})
