alias(
    name = "all",
    actual = "@%{llvm_repo_name}//:all",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang",
    actual = "@%{llvm_repo_name}//:clang",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang++",
    actual = "@%{llvm_repo_name}//:clang++",
    visibility = ["//visibility:public"],
)

alias(
    name = "ld",
    actual = "@%{llvm_repo_name}//:ld",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar",
    actual = "@%{llvm_repo_name}//:ar",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar_darwin",
    actual = "@%{llvm_repo_name}//:ar_darwin",
    visibility = ["//visibility:public"],
)

alias(
    name = "install_name_tool_darwin",
    actual = "@%{llvm_repo_name}//:install_name_tool_darwin",
    visibility = ["//visibility:public"],
)

# LLVM18 needs libtinfo.so.5 library as part of ubuntu 18 distributive
alias(
    name = "distro_libs",
    actual = "@%{llvm_repo_name}//:distro_libs",
    visibility = ["//visibility:public"],
)

alias(
    name = "asan_ignorelist",
    actual = "@%{llvm_repo_name}//:asan_ignorelist",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes",
    actual = "@%{llvm_repo_name}//:includes",
    visibility = ["//visibility:public"],
)

# This library is needed for LiteRT because it uses a compiler-specific
# built-in functions, and these functions are not provided by GCC 8.4.
alias(
    name = "libclang_rt",
    actual = "@%{llvm_repo_name}//:libclang_rt",
    visibility = ["//visibility:public"],
)

# Use when build CUDA by Clang (NVCC doesn't need it)
alias(
    name = "cuda_wrappers_headers",
    actual = "@%{llvm_repo_name}//:cuda_wrappers_headers",
    visibility = ["//visibility:public"],
)
