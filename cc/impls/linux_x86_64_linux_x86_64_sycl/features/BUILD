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

load("//cc/impls/linux_x86_64_linux_x86_64_sycl/features:rpath_feature.bzl", "cc_rpath_feature")
load(
    "//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_feature",
)

package(
    default_visibility = [
        "//cc/impls/linux_x86_64_linux_x86_64_sycl:__pkg__",
    ],
)

cc_feature(
    name = "no_as_needed",
    enabled = True,
    linker_flags = [
        "-Wl,-no-as-needed",
    ],
)

cc_rpath_feature(
    name = "runtime_library_search_directories",
    enabled = True,
)
