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
    "ACTION_NAME_GROUPS",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CPP_COMPILE_ACTION_NAMES",
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

def _import_openmp_feature_impl(ctx):

    print("_import_openmp_feature_impl: ==============================================")
    #print("_import_openmp_feature_impl: toolchain_import.name =", ctx.attr.toolchain_import.name)
    #print("_import_openmp_feature_impl: toolchain_import.package =", ctx.attr.toolchain_import.package)
    #print("_import_openmp_feature_impl: toolchain_import.workspace_name =", ctx.attr.toolchain_import.workspace_name)
    print("_import_openmp_feature_impl: workspace_root =", ctx.attr.toolchain_import.label.workspace_root)
    print("_import_openmp_feature_impl: workspace_name =", ctx.attr.toolchain_import.label.workspace_name)
    print("_import_openmp_feature_impl: package =", ctx.attr.toolchain_import.label.package)
    print("_import_openmp_feature_impl: dir(...) =", dir(ctx.attr.toolchain_import))
    Label.relative(relName)

    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]

    for path in toolchain_import_info.linking_context.runtime_paths.to_list():
        print("_import_openmp_feature_impl: ", path)

    linker_runtime_path_flags = depset([
        "-Wl,-rpath," + path
        for path in toolchain_import_info
            .linking_context.runtime_paths.to_list()
    ]).to_list()

    print("_import_openmp_feature_impl: len(linker_runtime_path_flags) = ", len(linker_runtime_path_flags))
    flag_sets = []
    if linker_runtime_path_flags:
        flag_sets.append(flag_set(
            actions = CC_LINK_EXECUTABLE_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = linker_runtime_path_flags,
                ),
            ],
        ))

    library_feature = _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        flag_sets = flag_sets,
        implies = ctx.attr.implies,
        provides = ctx.attr.provides,
    )
    return [library_feature, ctx.attr.toolchain_import[DefaultInfo]]

cc_toolchain_import_openmp_feature = rule(
    _import_openmp_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "toolchain_import": attr.label(),
    },
    provides = [FeatureInfo, DefaultInfo],
)
