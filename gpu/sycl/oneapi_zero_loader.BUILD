

# Level Zero system path example:
# l0_include_dir: /usr/include/level_zero
# l0_library_dir: /usr/lib/x86_64-linux-gnu

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

package(
    default_visibility = [
        "//cc/impls/linux_x86_64_linux_x86_64_sycl:__pkg__",
    ],
)

# TODO: Make libraries version insensitive
cc_toolchain_import(
    name = "libs",
    additional_libs = glob([
        "**/*",
    ]),
    shared_library = "libze_loader.so",
    visibility = ["//visibility:public"],
)
