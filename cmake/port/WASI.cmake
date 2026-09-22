# Port configuration for wasm32-wasi (WASI preview1) builds.
# Modelled on port/Emscripten.cmake.
#
# Depending on the CMake version, the Platform/WASI module may come
# from the toolchain's module path or from CMake itself (>= 4 ships
# one; CMP0017 makes it win).  Do not rely on either: (re)assert the
# variables the build depends on here.
set(WASI 1)
set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
set(CMAKE_EXECUTABLE_SUFFIX_C ".wasm")

# AlignOf.cmake style try-runs are cross-compiled; provide the answers.
set(ALIGNOF_INT64_T 8 CACHE STRING "Alignment for int64_t")
set(ALIGNOF_VOIDP   4 CACHE STRING "Alignment for pointers")
set(ALIGNOF_DOUBLE  8 CACHE STRING "Alignment for double")

set(PLHOME     "/swipl")
set(SWIPL_ARCH "wasm32-wasi")
set(USE_TCMALLOC OFF)
set(USE_SIGNALS OFF)
set(MULTI_THREADED OFF)
set(STATIC_EXTENSIONS ON)
set(BUILD_SWIPL_LD OFF)
set(SWIPL_SHARED_LIB OFF)

set(SRC_OS_SPECIFIC wasi/pl-wasi.c)

# __unix__: wasi-libc is close enough to POSIX for SWI-Prolog's
# purposes and the Emscripten toolchain also defines it; clang's
# wasm32-wasi target does not, which loses e.g. the POSIX versions of
# PrologPath()/OsPath() in pl-os.c.
add_compile_definitions(__unix__=1)

# setjmp()/longjmp() via the wasm exception-handling proposal (same
# option name as port/Emscripten.cmake).  Requires a wasi-libc with
# libsetjmp (wasi-sdk >= 21), clang >= 20 for exnref codegen, and a
# runtime implementing the standardized EH proposal.  Without it,
# O_THROW=0 selects the synchronous exception paths and disables
# PL_throw().
# (The option itself is declared by the top-level CMakeLists.txt,
# default OFF; pass -DWASM_EXCEPTIONS=ON.)
if(WASM_EXCEPTIONS)
  # -wasm-use-legacy-eh=false: emit the standardized exnref/try_table
  # encoding (what wasmtime implements) instead of legacy try/catch.
  # SHELL: keeps the repeated -mllvm pairs intact (cmake would
  # otherwise de-duplicate the second -mllvm).
  add_compile_options("SHELL:-mllvm -wasm-enable-sjlj"
                      "SHELL:-mllvm -wasm-use-legacy-eh=false")
  link_libraries(setjmp)
else()
  add_compile_definitions(O_THROW=0)
endif()

# No dlopen(); extensions are linked statically (STATIC_EXTENSIONS).
# No signals; USE_SIGNALS=OFF keeps O_SIGNALS undefined.
