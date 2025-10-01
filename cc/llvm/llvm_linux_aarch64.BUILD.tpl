alias(
    name = "all",
    actual = "@llvm18_linux_x86_64//:all",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang",
    actual = "@llvm18_linux_x86_64//:clang",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang++",
    actual = "@llvm18_linux_x86_64//:clang++",
    visibility = ["//visibility:public"],
)

alias(
    name = "ld",
    actual = "@llvm18_linux_x86_64//:ld",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar",
    actual = "@llvm18_linux_x86_64//:ar",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar_darwin",
    actual = "@llvm18_linux_x86_64//:ar_darwin",
    visibility = ["//visibility:public"],
)

alias(
    name = "install_name_tool_darwin",
    actual = "@llvm18_linux_x86_64//:install_name_tool_darwin",
    visibility = ["//visibility:public"],
)

# LLVM18 needs libtinfo.so.5 library as part of ubuntu 18 distributive
alias(
    name = "distro_libs",
    actual = "@llvm18_linux_x86_64//:distro_libs",
    visibility = ["//visibility:public"],
)

alias(
    name = "asan_ignorelist",
    actual = "@llvm18_linux_x86_64//:asan_ignorelist",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes",
    actual = "@llvm18_linux_x86_64//:includes",
    visibility = ["//visibility:public"],
)

# This library is needed for LiteRT because it uses a compiler-specific
# built-in functions, and these functions are not provided by GCC 8.4.
alias(
    name = "libclang_rt",
    actual = "@llvm18_linux_x86_64//:libclang_rt",
    visibility = ["//visibility:public"],
)

# Use when build CUDA by Clang (NVCC doesn't need it)
alias(
    name = "cuda_wrappers_headers",
    actual = "@llvm18_linux_x86_64//:cuda_wrappers_headers",
    visibility = ["//visibility:public"],
)
