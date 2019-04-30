using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libfinufft"], :libfinufft),
]

verbose = true

# Download binaries from hosted location
bin_prefix = "https://github.com/ludvigak/FINUFFTBuilder/releases/download/0.1.3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.aarch64-linux-gnu.tar.gz", "0e6e6c6df79e62c180e50df832d6c7d0fea1b9a84de9f5f115ddfafeec6ff502"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.aarch64-linux-musl.tar.gz", "d32ed85b3e5715c56587198e17c9dd33f082b9fd27f21f3f487bc3db76ca9f00"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.arm-linux-gnueabihf.tar.gz", "2099899fb034664e755f581ed09df522507fc9d414d57655e3c987073f948ea1"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.arm-linux-musleabihf.tar.gz", "371fe5971bbef3063849df1af94ea2e1a2704bb75f3ce60e15e5cb2099e1022d"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.i686-linux-gnu.tar.gz", "da1c9e3acbceccdf8fb4b9676a3f925c5729c8e1c4ea20bb62804f48bb6ae21c"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.i686-linux-musl.tar.gz", "7d09cb03b5fe78032dbb9fe19970aca7a3e5e67a2f3c397c43a24b6ecb183ea5"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.powerpc64le-linux-gnu.tar.gz", "ee79858d721a299807013f102cb6a25fd60328415f1832b63e37d485fd1b0677"),
    MacOS(:x86_64) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.x86_64-apple-darwin14.tar.gz", "a1c2e6b92460663d510e16ca8bb56d5b9d3f3c7fef12ce219c341a2e8997a1fb"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.x86_64-linux-gnu.tar.gz", "afc022a2610edfe5085970c57b798d4f1fcb6fee0613f2d5d9d372bce50ff5cb"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.x86_64-linux-musl.tar.gz", "998ad0b63f3b27bb094492f58cc001577077d7cb1bf297fd7a7562587a27ade7"),
    FreeBSD(:x86_64) => ("$bin_prefix/FINUFFTBuilder.v0.1.3.x86_64-unknown-freebsd11.1.tar.gz", "180ce5893da3b37b858ce717d4d7f7c72cef2b38ab67e1deb14e5fc331741c0f"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

using Libdl
if Sys.KERNEL == :Darwin
    dlopen("usr/lib/libfinufft.dylib")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
