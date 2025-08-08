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

load(
    "@rules_ml_toolchain//third_party/nccl/hermetic:nccl_configure.bzl",
    "ENVIRONS",
    "nccl_autoconf_impl",
)

nccl_configure = repository_rule(
    environ = ENVIRONS,
    implementation = nccl_autoconf_impl,
    attrs = {
        "environ": attr.string_dict(),
        "generated_names_tpl": attr.label(default = Label("//third_party/nccl:generated_names.bzl.tpl")),
        "build_defs_tpl": attr.label(default = Label("//third_party/nccl:build_defs.bzl.tpl")),
    },
)
