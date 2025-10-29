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

def _get_origin_path(lib_file):
    relative_path = lib_file.short_path
    print("_get_origin_path: relative_path = ", relative_path)

    repo_name = lib_file.owner.workspace_name

    path_in_repo = lib_file.path.removesuffix(lib_file.basename).removesuffix(repo_name + '/')

    origin_prefix = "$ORIGIN/../../../../../../"
    print("_get_origin_path: Result: ", origin_prefix + "external/" + repo_name + "/" + path_in_repo)
    return origin_prefix + "external/" + repo_name + "/" + path_in_repo

def _import_openmp_feature_impl(ctx):

    print("_import_openmp_feature_impl: ==============================================", dir(ctx))
    print("_import_openmp_feature_impl: bin_dir = ", ctx.bin_dir.path)
    print("_import_openmp_feature_impl: build_file_path = ", ctx.build_file_path)
    print("_import_openmp_feature_impl: genfiles_dir = ", ctx.genfiles_dir)
    print("_import_openmp_feature_impl: runfiles = ", dir(ctx.runfiles))
    #print("_import_openmp_feature_impl: toolchain_import.name =", ctx.attr.toolchain_import.name)
    #print("_import_openmp_feature_impl: toolchain_import.package =", ctx.attr.toolchain_import.package)
    #print("_import_openmp_feature_impl: toolchain_import.workspace_name =", ctx.attr.toolchain_import.workspace_name)
    print("_import_openmp_feature_impl: dir(...) =", dir(ctx.attr.toolchain_import))
    print("_import_openmp_feature_impl: workspace_root =", ctx.attr.toolchain_import.label.workspace_root)
    print("_import_openmp_feature_impl: workspace_name =", ctx.attr.toolchain_import.label.workspace_name)
    print("_import_openmp_feature_impl: package =", ctx.attr.toolchain_import.label.package)
    print("_import_openmp_feature_impl: data_runfiles =", dir(ctx.attr.toolchain_import.data_runfiles))

    runtime_paths = {}
    for file in ctx.attr.toolchain_import.files.to_list():
        print("_import_openmp_feature_impl: file.basename =", file.basename)
        print("_import_openmp_feature_impl: file.dirname =", file.dirname)
        print("_import_openmp_feature_impl: file.extension =", file.extension)
        print("_import_openmp_feature_impl: file.is_source =", file.is_source)
        print("_import_openmp_feature_impl: file.path =", file.path)
        print("_import_openmp_feature_impl: file.root =", dir(file.root))
        print("_import_openmp_feature_impl: file.short_path =", file.short_path)
        print("_import_openmp_feature_impl: dir(file) =", dir(file))
        #print("_import_openmp_feature_impl: file.tree_relative_path =", file.tree_relative_path)
        #print("_import_openmp_feature_impl: origin_path =", _get_origin_path(file))


        if file.path not in runtime_paths:
            runtime_paths[file.dirname] = file

    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]

    linker_runtime_path_flags = depset([
        "-Wl,-rpath," + _get_origin_path(runtime_paths[rpath])
        for rpath in runtime_paths
    ]).to_list()

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
        "toolchain_import": attr.label(providers = [CcToolchainImportInfo]),
    },
    provides = [FeatureInfo, DefaultInfo],
)
