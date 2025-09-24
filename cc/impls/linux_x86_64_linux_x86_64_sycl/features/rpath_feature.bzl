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

def all_link_actions():
    return [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

def _iterate_flag_group(iterate_over, flags = [], flag_groups = []):
    return flag_group(
        iterate_over = iterate_over,
        expand_if_available = iterate_over,
        flag_groups = flag_groups,
        flags = flags,
    )

def _rpath_feature(ctx):
    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        flag_sets = [
            flag_set(
                actions = all_link_actions(),
                flag_groups = [
                    #                    flag_group(flags = ["-Wl,-no-as-needed"]),
                    #                    flag_group(
                    #                        flags = ["@%{linker_param_file}"],
                    #                        expand_if_available = "linker_param_file",
                    #                    ),
                    #                    _iterate_flag_group(
                    #                        flags = ["%{linkstamp_paths}"],
                    #                        iterate_over = "linkstamp_paths",
                    #                    ),
                    #                    flag_group(
                    #                        flags = ["-o", "%{output_execpath}"],
                    #                        expand_if_available = "output_execpath",
                    #                    ),
                    #                    _iterate_flag_group(
                    #                        flags = ["-L%{library_search_directories}"],
                    #                        iterate_over = "library_search_directories",
                    #                    ),
                    _iterate_flag_group(
                        iterate_over = "runtime_library_search_directories",
                        flags = [
                            "-Wl,-rpath,$ORIGIN/../../%{runtime_library_search_directories}",
                        ],
                    ),
                    #                    _iterate_flag_group(
                    #                        flags = ["%{user_link_flags}"],
                    #                        iterate_over = "user_link_flags",
                    #                    ),
                    #                    flag_group(
                    #                        flags = ["-Wl,--gdb-index"],
                    #                        expand_if_available = "is_using_fission",
                    #                    ),
                    #                    flag_group(
                    #                        flags = ["-Wl,-S"],
                    #                        expand_if_available = "strip_debug_symbols",
                    #                    ),
                ],
            ),
        ],
    )

cc_rpath_feature = rule(
    _rpath_feature,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
    },
    provides = [FeatureInfo],
)
