using BinaryBuilder

# Collection of sources required to build ERFABuilder
sources = [
    "https://github.com/liberfa/erfa/releases/download/v1.4.0/erfa-1.4.0.tar.gz" =>
    "035b7f0ad05c1191b8588191ba4b19ba0f31afa57ad561d33bd5417d9f23e460",
]

script = raw"""
cd $WORKSPACE/srcdir
cd erfa-1.4.0/
if [[ ${target} == i686-w64* ]] || [[ ${target} == x86_64-w64* ]]; then
    sed -i 's/LT_INIT/LT_INIT([win32-dll])/' configure.ac
    sed -i 's/liberfa_la_LDFLAGS = -version-info \$(VI_ALL)/liberfa_la_LDFLAGS = -no-undefined -version-info $(VI_ALL)/' src/Makefile.am
fi
autoreconf -fi
./configure --prefix=$prefix --host=$target
make -j${nproc}
make install
"""

# Build on all default platforms
platforms = supported_platforms()

# No dependencies
dependencies = []

products = prefix -> [
    LibraryProduct(prefix, "liberfa", :liberfa)
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "liberfa", sources, script, platforms, products, dependencies)
