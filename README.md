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

# Configure C++ toolchains

### How to configure toolchains for ML project

Add below code before CUDA initialization in WORKSPACE file

```
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "f4f41445e4652e7e3c8e719121a4ed31dd161aa495f6704b6d972082a262658c",
    strip_prefix = "rules_ml_toolchain-353817f8f851f3291be221fc72ad0fcb00a4500c",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/353817f8f851f3291be221fc72ad0fcb00a4500c.tar.gz",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64_cuda")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64_cuda")

```

It must be ensured that builds for Linux x86_64 / aarch64 are run without the `--noincompatible_enable_cc_toolchain_resolution` 
flag. Furthermore, reliance on environment variables like `CLANG_COMPILER_PATH`, `BAZEL_COMPILER`, `CC`, or `CXX` 
must be avoided.

For diagnosing the utility set being used during build or test execution, the `--subcommands` flag should be appended 
to the Bazel command. This will facilitate checking that the compiler or linker are not being used from your machine.

## How to run this project tests
### CPU Hermetic tests
Project supports CPU hermetic builds on:
* Linux x86_64 / aarch64
* macOS aarch64 - *In Development*

The command allows you to run hermetic build tests:

`bazel test //cc/tests/cpu:all`

##### Non-hermetic CPU builds
When executor and a target are the same, you still can run non-hermetic build. Command should look like:

`bazel build //cc/tests/cpu:all --config=clang_local`

For details, look at the `.bazelrc` file, specifically the `clang_local` configuration.

### GPU Hermetic tests
Project supports GPU hermetic builds on Linux x86_64 / aarch64. Running tests requires a machine with an NVIDIA GPU.

Hermetic tests could be run with the help of the command:
###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

#### Non-hermetic GPU tests
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