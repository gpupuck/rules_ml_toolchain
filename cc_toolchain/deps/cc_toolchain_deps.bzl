# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
#load("//cc_toolchain/cuda:nvcc_wrapper_configure.bzl", "nvcc_wrapper_configure")

#load("@bazel_tools//tools/build_defs/repo:local.bzl", "local_repository")
load(":http_archive_bazel7.bzl", "http_archive_bazel7")  # Remove this line after updating bazel to 7.3.0 or newer

def cc_toolchain_deps():
    #    if "nvcc_wrapper" not in native.existing_rules():
    #        print("Initializing NVCC wrapper")
    #        nvcc_wrapper_configure(name = "nvcc_wrapper")

    if "sysroot_linux_x86_64" not in native.existing_rules():
        # Produce wheels with tag manylinux_2_27_x86_64
        http_archive(
            name = "sysroot_linux_x86_64",
            sha256 = "5f62ca2978b4243cfca5d3798e78f4ced50b07bbc7ed1299ccbb8a715931304c",
            urls = ["https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_x86_64_sysroot.tar.xz"],
            build_file = Label("//cc_toolchain/config:sysroot_ubuntu18_x86_64.BUILD"),
            strip_prefix = "ubuntu18_x86_64_sysroot",
        )

    # Produce wheels with tag manylinux_2_35_x86_64
    #    if "sysroot_linux_x86_64" not in native.existing_rules():
    #        http_archive(
    #            name = "sysroot_linux_x86_64",
    #            #sha256 = "d19c4b010a75eb9d599f055c834a993d848880c936d7d91366a7c3765ad028ae",
    #            urls = ["https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_x86_64_sysroot_gcc9.tar.xz"],
    #            build_file = Label("//cc_toolchain/config:sysroot_ubuntu18_x86_64_gcc9.BUILD"),
    #            strip_prefix = "ubuntu18_x86_64_sysroot",
    #        )

    if "sysroot_linux_aarch64" not in native.existing_rules():
        http_archive(
            name = "sysroot_linux_aarch64",
            sha256 = "d883a1d664500f11bb49aa70c650a9e68d49341324c447f9abda77ec2f335ac5",
            urls = ["https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_aarch64-sysroot.tar.xz"],
            build_file = Label("//cc_toolchain/config:sysroot_ubuntu18_aarch64.BUILD"),
            strip_prefix = "ubuntu18_aarch64-sysroot",
        )

    if "sysroot_macos_aarch64" not in native.existing_rules():
        native.new_local_repository(
            name = "sysroot_macos_aarch64",
            build_file = "//cc_toolchain/config:sysroot_macos_aarch64.BUILD",
            path = "cc_toolchain/sysroots/macos_arm64/MacOSX.sdk",
        )

    if "llvm_linux_x86_64" not in native.existing_rules():
        # Replace 'http_archive_bazel7' by 'http_archive' after updating bazel to 7.3.0 or newer
        http_archive(
            name = "llvm_linux_x86_64",
            url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz",
            sha256 = "4a5ec53951a584ed36f80240f6fbf8fdd46b4cf6c7ee87cc2d5018dc37caf679",
            build_file = Label("//cc_toolchain/config:llvm19_linux_x86_64.BUILD"),
            strip_prefix = "LLVM-19.1.7-Linux-X64",
        )

    if "llvm_macos_aarch64" not in native.existing_rules():
        http_archive(
            name = "llvm_macos_aarch64",
            url = "https://github.com/yuriit-google/sysroots/raw/ba192c408e0f82c6c9a5b92712038edaa64326d6/archives/ubuntu18_aarch64-sysroot.tar.xz",
            sha256 = "4573b7f25f46d2a9c8882993f091c52f416c83271db6f5b213c93f0bd0346a10",
            build_file = Label("//cc_toolchain/config:llvm_macos_aarch64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-arm64-apple-macos11",
        )
