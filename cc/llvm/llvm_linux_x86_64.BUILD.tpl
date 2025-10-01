alias(
    name = "all",
    actual = "%{llvmX}//:all",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang",
    actual = "%{llvmX}//:clang",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang++",
    actual = "%{llvmX}//:clang++",
    visibility = ["//visibility:public"],
)

alias(
    name = "ld",
    actual = "%{llvmX}//:ld",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar",
    actual = "%{llvmX}//:ar",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar_darwin",
    actual = "%{llvmX}//:ar_darwin",
    visibility = ["//visibility:public"],
)

alias(
    name = "install_name_tool_darwin",
    actual = "%{llvmX}//:install_name_tool_darwin",
    visibility = ["//visibility:public"],
)

# LLVM18 needs libtinfo.so.5 library as part of ubuntu 18 distributive
alias(
    name = "distro_libs",
    actual = "%{llvmX}//:distro_libs",
    visibility = ["//visibility:public"],
)

alias(
    name = "asan_ignorelist",
    actual = "%{llvmX}//:asan_ignorelist",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes",
    actual = "%{llvmX}//:includes",
    visibility = ["//visibility:public"],
)

# This library is needed for LiteRT because it uses a compiler-specific
# built-in functions, and these functions are not provided by GCC 8.4.
alias(
    name = "libclang_rt",
    actual = "%{llvmX}//:libclang_rt",
    visibility = ["//visibility:public"],
)

# Use when build CUDA by Clang (NVCC doesn't need it)
alias(
    name = "cuda_wrappers_headers",
    actual = "%{llvmX}//:cuda_wrappers_headers",
    visibility = ["//visibility:public"],
)
