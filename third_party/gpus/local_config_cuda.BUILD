load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

package(default_visibility = ["//visibility:public"])

# CUDA flag for backward compatibility

alias(
    name = "enable_cuda",
    actual = "@rules_ml_toolchain//common:enable_cuda",
)

alias(
    name = "is_cuda_enabled",
    actual = "@rules_ml_toolchain//common:is_cuda_enabled",
)

alias(
    name = "is_cuda_disabled",
    actual = "@rules_ml_toolchain//common:is_cuda_disabled",
)

# Build flag to select CUDA compiler.
#
# Set with '--@local_config_cuda//:cuda_compiler=...', or indirectly with
# ./configure, '--config=cuda' or '--config=cuda_clang'.
string_flag(
    name = "cuda_compiler",
    build_setting_default = "nvcc",
    values = [
        "clang",
        "nvcc",
    ],
)

# Config setting whether CUDA device code should be compiled with clang.
config_setting(
    name = "is_cuda_compiler_clang",
    flag_values = {":cuda_compiler": "clang"},
)

# Config setting whether CUDA device code should be compiled with nvcc.
config_setting(
    name = "is_cuda_compiler_nvcc",
    flag_values = {":cuda_compiler": "nvcc"},
)
