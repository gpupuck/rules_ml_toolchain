# Hermetic Toolchains for ML

> [!WARNING]
> This project is under active development and is not yet ready for production use.

This project provides Bazel rules to achieve hermetic and cross-platform builds.

Hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* Isolation: Builds are isolated from the host system, minimizing unexpected dependencies and side effects.

Cross-Platform builds benefits:
* Single Source of Truth: Develop and maintain a single codebase that can be built for various target platforms (e.g., Linux, macOS).
* Efficiency: Streamlines the build and release process for multiple platforms.

# C++ toolchains

### How to configure ML toolchain in your project

Add this code before CUDA initialization in WORKSPACE file

```
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "562e0517f4e833afe0de7bb8da49f9adafcbca30a8259f118a65b4adf533b51f",
    strip_prefix = "rules_ml_toolchain-4995c0be587c6e173fe8cf8dc614f92011f7913d",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/4995c0be587c6e173fe8cf8dc614f92011f7913d.zip",
    ],
)

load(
    "@rules_ml_toolchain//cc_toolchain/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc_toolchain:lx64_lx64")
register_toolchains("@rules_ml_toolchain//cc_toolchain:lx64_lx64_cuda")

```

Make sure that builds for Linux x86_64 run without `--noincompatible_enable_cc_toolchain_resolution` flag 
and without some environment variables like `CLANG_COMPILER_PATH`, `BAZEL_COMPILER`, `CC`, `CXX`, etc.
After all modifications builds for Linux x86_64 and CUDA should be run hermetically without any additional changes.

### How to run tests
#### CPU Hermetic builds
Project supports CPU hermetic builds on:
* Linux x86_64
* macOS aarch64

The command allows you to run hermetic build tests:

`bazel test //cc_toolchain/tests/cpu:all`

If project doesn't support cross-platform builds for specified platform,
it will use host utilities and host sysroot for running such build.

#### GPU Hermetic builds 
Requires machine with NVIDIA GPU

Project supports GPU hermetic builds on:
* Linux x86_64

You could run hermetic build and test with help of command:
###### Build by Clang
`bazel test //cc_toolchain/tests/gpu:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc_toolchain/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

#### Non-hermetic builds
When executor and a target are the same, you still can run non-hermetic build. Command should look like:

`bazel build //cc_toolchain/tests/cpu:all --//cc_toolchain/config:enable_hermetic_cc=False`

### Cross-platform builds
Project supports cross-platform builds only on Linux x86_64 executor 
and allows build for such targets:
* Linux aarch64
* macOS aarch64

#### Build for Linux aarch64
`bazel build //cc_toolchain/tests/cpu/... --platforms=//cc_toolchain/config:linux_aarch64`

#### Build for macOS aarch64
[Prepare SDK](cc_toolchain/sysroots/macos_arm64/README.md) before run the following command.

`bazel build //cc_toolchain/tests/... --platforms=//cc_toolchain/config:macos_aarch64`
