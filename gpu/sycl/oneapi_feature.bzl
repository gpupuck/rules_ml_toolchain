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

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
    "DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "env_entry",
    "env_set",
    "feature",
    "flag_group",
    "flag_set",
    _feature = "feature",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)

ALL_ACTIONS = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cc_flags_make_variable,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.lto_indexing,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.clif_match,
]

def _get_lib_path_var(ctx):
    path_var = ""
    for path in ctx.attr.lib_paths:
        path_var += (path.label.workspace_root + "/" + path.label.name + ":")
    return path_var if not path_var or not path_var.endswith(":") else path_var[:-1]

def _oneapi_feature_impl(ctx):
    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        env_sets = [env_set(
            actions = ALL_ACTIONS,
            env_entries = [
                env_entry("ONEAPI_LIBRARY_PATH", _get_lib_path_var(ctx)),
                env_entry("ONEAPI_ICPX_PATH", (ctx.attr.icpx_path.label.workspace_root + "/" + ctx.attr.icpx_path.label.name)),
                env_entry("ONEAPI_CLANG_PATH", (ctx.attr.clang_path.label.workspace_root + "/" + ctx.attr.clang_path.label.name)),
                env_entry("ONEAPI_VERSION", ctx.attr.version),
                env_entry("ONEAPI_VERBOSE", "1" if ctx.attr.verbose else "0"),
            ],
        )],
    )

oneapi_feature = rule(
    _oneapi_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "lib_paths": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "icpx_path": attr.label(
            allow_single_file = True,
            mandatory = False,
        ),
        "clang_path": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
        "verbose": attr.bool(
            default = False,
        ),
    },
    provides = [FeatureInfo],
)
