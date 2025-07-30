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

# DEPRECATED TOOLCHAINS, USE //cc:linux_x86_64_linux_x86_64 and //cc:linux_x86_64_linux_x86_64_cuda INSTEAD

alias(
    name = "lx64_lx64",
    actual = "@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64",
)

alias(
    name = "lx64_lx64_cuda",
    actual = "@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64_cuda",
)
