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

""" TODO(yuriit): Replace this stub file with a file that has real logic """

load("@cuda_cccl//:version.bzl", _cccl_version = "VERSION")
load("@cuda_cublas//:version.bzl", _cublas_version = "VERSION")
load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")
load("@cuda_cudnn//:version.bzl", _cudnn_version = "VERSION")
load("@cuda_cufft//:version.bzl", _cufft_version = "VERSION")
load("@cuda_cupti//:version.bzl", _cupti_version = "VERSION")
load("@cuda_curand//:version.bzl", _curand_version = "VERSION")
load("@cuda_cusolver//:version.bzl", _cusolver_version = "VERSION")
load("@cuda_cusparse//:version.bzl", _cusparse_version = "VERSION")
load("@cuda_nvcc//:version.bzl", _nvcc_version = "VERSION")
load("@cuda_nvdisasm//:version.bzl", _nvdisasm_version = "VERSION")
load("@cuda_nvjitlink//:version.bzl", _nvjitlink_version = "VERSION")
load("@cuda_nvml//:version.bzl", _nvml_version = "VERSION")
load("@cuda_nvtx//:version.bzl", _nvtx_version = "VERSION")
load("@llvm_linux_x86_64//:version.bzl", _llvm_hermetic_version = "VERSION")

load(
    "//third_party/gpus/cuda/hermetic:cuda_configure.bzl",
    "cuda_configure_impl"
)

cuda_configure = repository_rule(
    implementation = cuda_configure_impl,
    attrs = {
        "environ": attr.string_dict(),
        "cccl_version": attr.label(default = Label("@cuda_cccl//:version.bzl")),
        "cublas_version": attr.label(default = Label("@cuda_cublas//:version.bzl")),
        "cudart_version": attr.label(default = Label("@cuda_cudart//:version.bzl")),
        "cudnn_version": attr.label(default = Label("@cuda_cudnn//:version.bzl")),
        "cufft_version": attr.label(default = Label("@cuda_cufft//:version.bzl")),
        "cupti_version": attr.label(default = Label("@cuda_cupti//:version.bzl")),
        "curand_version": attr.label(default = Label("@cuda_curand//:version.bzl")),
        "cusolver_version": attr.label(default = Label("@cuda_cusolver//:version.bzl")),
        "cusparse_version": attr.label(default = Label("@cuda_cusparse//:version.bzl")),
        "nvcc_binary": attr.label(default = Label("@cuda_nvcc//:bin/nvcc")),
        "nvcc_version": attr.label(default = Label("@cuda_nvcc//:version.bzl")),
        "nvjitlink_version": attr.label(default = Label("@cuda_nvjitlink//:version.bzl")),
        "nvml_version": attr.label(default = Label("@cuda_nvml//:version.bzl")),
        "nvtx_version": attr.label(default = Label("@cuda_nvtx//:version.bzl")),
        "local_config_cuda_build_file": attr.label(default = Label("//third_party/gpus:local_config_cuda.BUILD")),
        "build_defs_tpl": attr.label(default = Label("//third_party/gpus/cuda:build_defs.bzl.tpl")),
        "cuda_build_tpl": attr.label(default = Label("//third_party/gpus/cuda/hermetic:BUILD.tpl")),
        "cuda_config_tpl": attr.label(default = Label("//third_party/gpus/cuda:cuda_config.h.tpl")),
        "cuda_config_py_tpl": attr.label(default = Label("//third_party/gpus/cuda:cuda_config.py.tpl")),
        "crosstool_wrapper_driver_is_not_gcc_tpl": attr.label(default = Label("//third_party/gpus/crosstool:clang/bin/crosstool_wrapper_driver_is_not_gcc.tpl")),
        "crosstool_build_tpl": attr.label(default = Label("//third_party/gpus/crosstool:BUILD.tpl")),
        "cc_toolchain_config_tpl": attr.label(default = Label("//third_party/gpus/crosstool:cc_toolchain_config.bzl.tpl")),
    },
)
