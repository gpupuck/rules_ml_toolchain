# Hermetic Toolchains for ML

This project provides Bazel rules for ML project to achieve hermetic builds.

C++ and CUDA hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* Isolation: Builds are isolated from the host system, minimizing unexpected dependencies and side effects.

<!--
C++ cross-platform builds benefits:
* Single Source of Truth: Develop and maintain a single codebase that can be built for various target platforms (e.g., Linux, macOS).
* Efficiency: Streamlines the build and release process for multiple platforms.
-->

## Configure hermetic C++ toolchains

Add the following code before the CUDA initialization block in WORKSPACE file:

### C++17
```
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "1a855dd94eebedae69d1804e8837ad70b8018358a0a03eea0bec71d7dc2b096a",
    strip_prefix = "rules_ml_toolchain-d321763a84c900bc29b4f5459a4f81fad19b2356",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/d321763a84c900bc29b4f5459a4f81fad19b2356.tar.gz",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
```
### C++20
```
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "7421260948827896a51c785e51885de279bb769a32eeeabf18c633f6589c3371",
    strip_prefix = "rules_ml_toolchain-c275b48326c8c3bdc1147d790c8ede2ff16eb3c3",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/c275b48326c8c3bdc1147d790c8ede2ff16eb3c3.tar.gz",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")

```

It must be ensured that builds for Linux x86_64 / aarch64 are run without the `--noincompatible_enable_cc_toolchain_resolution` 
flag. Furthermore, reliance on environment variables like `CLANG_COMPILER_PATH`, `BAZEL_COMPILER`, `CC`, or `CXX` 
must be avoided.

For diagnosing the utility set being used during build or test execution, the `--subcommands` flag should be appended 
to the Bazel command. This will facilitate checking that the compiler or linker are not being used from your machine.

## Configure hermetic CUDA, CUDNN, NCCL and NVSHMEM
For detailed instructions on how to configure hermetic CUDA, CUDNN, NCCL and NVSHMEM, [click this link](gpu/).

## How to run this project tests
### CPU hermetic tests
Project supports CPU hermetic builds on:
* Linux x86_64 / aarch64
* macOS aarch64 - *In Development*

The command allows you to run hermetic build tests:

`bazel test //cc/tests/cpu:all`

#### Non-hermetic CPU builds
When executor and a target are the same, you still can run non-hermetic build. Command should look like:

`bazel build //cc/tests/cpu:all --config=clang_local`

For details, look at the `.bazelrc` file, specifically the `clang_local` configuration.

### CUDA and hermetic toolchains tests
Project supports GPU hermetic builds on Linux x86_64 / aarch64. Running tests requires a machine with an NVIDIA GPU.

Hermetic tests could be run with the help of the command:
###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

#### CUDA and non-hermetic toolchains tests
When the executor and the target are the same, a non-hermetic GPU build can still be run.

###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda_clang_local --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda_clang_local --config=cuda_libraries_from_stubs`

For details, look at the `.bazelrc` file, specifically the `cuda_clang_local` configuration.

<!--
### Cross-platform builds
Project supports cross-platform builds only on Linux x86_64 executor 
and allows build for such targets:
* Linux aarch64
* macOS aarch64

#### Build for Linux aarch64
`bazel build //cc/tests/cpu/... --platforms=//common:linux_aarch64`

#### Build for macOS aarch64
[Prepare SDK](cc/sysroots/darwin_aarch64/README.md) before run the following command.

`bazel build //cc/tests/cpu/... --platforms=//common:macos_aarch64`
-->