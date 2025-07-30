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

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")

# DEPRECATED TOOLCHAINS, USE //cc:linux_x86_64_linux_x86_64 and //cc:linux_x86_64_linux_x86_64_cuda

toolchain(
    name = "lx64_lx64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/cpu:toolchain_linux_x86_64_linux_x86_64",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

toolchain(
    name = "lx64_lx64_cuda",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_enabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/cuda:toolchain_linux_x86_64_linux_x86_64_cuda",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
