cmake_minimum_required(VERSION 2.6)

project(DCE12MIPS-Asmblr)

SET ( CMAKE_BUILD_TYPE "Debug" )
#SET ( CMAKE_BUILD_TYPE "Release" )

SET(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g -ggdb -DDEBUG")
SET(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall -DRELEASE")

#add_subdirectory()     # You may use it~
