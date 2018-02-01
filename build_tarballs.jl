using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686),
    BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

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
    autoreconf -fi
fi
./configure --prefix=/ --host=$target
make
make install

"""

products = prefix -> [
    LibraryProduct(prefix,"liberfa")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "liberfa", platforms, sources, script, products)

