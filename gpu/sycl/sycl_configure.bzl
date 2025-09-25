"""Repository rule for SYCL autoconfiguration.
`sycl_configure` depends on the following environment variables:
  * `TF_NEED_SYCL`: Whether to enable building with SYCL.
  * `GCC_HOST_COMPILER_PATH`: The GCC host compiler path
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "//gpu/sycl:sycl_redist_versions.bzl",
    "BUILD_TEMPLATES",
    "REDIST_DICT",
)
load(
    "//third_party/remote_config:common.bzl",
    "err_out",
    "execute",
    "files_exist",
    "get_bash_bin",
    "get_host_environ",
    "get_python_bin",
    "raw_exec",
    "realpath",
    "which",
)

_GCC_HOST_COMPILER_PATH = "GCC_HOST_COMPILER_PATH"
_GCC_HOST_COMPILER_PREFIX = "GCC_HOST_COMPILER_PREFIX"
_CLANG_HOST_COMPILER_PATH = "CLANG_COMPILER_PATH"
_CLANG_HOST_COMPILER_PREFIX = "CLANG_HOST_COMPILER_PATH"

def _mkl_include_path(sycl_config):
    return sycl_config.mkl_include_dir

def _mkl_library_path(sycl_config):
    return sycl_config.mkl_library_dir

def _l0_include_path(sycl_config):
    return sycl_config.l0_include_dir

def _l0_library_path(sycl_config):
    return sycl_config.l0_library_dir

def _sycl_header_path(ctx, sycl_config, bash_bin):
    sycl_header_path = sycl_config.sycl_toolkit_path
    include_dir = sycl_header_path + "/include"
    if not files_exist(ctx, [include_dir], bash_bin)[0]:
        sycl_header_path = sycl_header_path + "/linux"
        include_dir = sycl_header_path + "/include"
        if not files_exist(ctx, [include_dir], bash_bin)[0]:
            auto_configure_fail("Cannot find sycl headers in {}".format(include_dir))
    return sycl_header_path

def _sycl_include_path(ctx, sycl_config, bash_bin):
    """Generates the cxx_builtin_include_directory entries for sycl inc dirs.

    Args:
      ctx: The repository context.
      sycl_config: The path to the gcc host compiler.

    Returns:
      A string containing the Starlark string for each of the gcc
      host compiler include directories, which can be added to the CROSSTOOL
      file.
    """
    inc_dirs = []

    inc_dirs.append(_mkl_include_path(sycl_config))
    inc_dirs.append(_sycl_header_path(ctx, sycl_config, bash_bin) + "/include")
    inc_dirs.append(_sycl_header_path(ctx, sycl_config, bash_bin) + "/include/sycl")

    return inc_dirs

def enable_sycl(ctx):
    """Returns whether to build with SYCL support."""
    return bool(ctx.getenv("TF_NEED_SYCL", "").strip())

def _use_icpx_and_clang(ctx):
    """Returns whether to use ICPX for SYCL and Clang for C++."""
    return ctx.getenv("TF_ICPX_CLANG", "").strip()

def auto_configure_fail(msg):
    """Output failure message when auto configuration fails."""
    red = "\033[0;31m"
    no_color = "\033[0m"
    fail("\n%sAuto-Configuration Error:%s %s\n" % (red, no_color, msg))

def find_sycl_config(ctx):
    """Returns SYCL config dictionary from running find_sycl_config.py"""
    python_bin = get_python_bin(ctx)
    exec_result = execute(ctx, [python_bin, ctx.attr._find_sycl_config])
    if exec_result.return_code:
        auto_configure_fail("Failed to run find_sycl_config.py: %s" % err_out(exec_result))

    # Parse the dict from stdout.
    return dict([tuple(x.split(": ")) for x in exec_result.stdout.splitlines()])

def _tpl_path(ctx, labelname):
    tpl = "//gpu/sycl%s.tpl" if labelname.startswith(":") else "//gpu/sycl/%s.tpl"
    print("_tpl_path: tpl =", tpl % labelname)
    return ctx.path(Label(tpl % labelname))

_INC_DIR_MARKER_BEGIN = "#include <...>"

_DUMMY_CROSSTOOL_BZL_FILE = """
def error_gpu_disabled():
  fail("ERROR: Building with --config=sycl but TensorFlow is not configured " +
       "to build with GPU support. Please re-run ./configure and enter 'Y' " +
       "at the prompt to build with GPU support.")

  native.genrule(
      name = "error_gen_crosstool",
      outs = ["CROSSTOOL"],
      cmd = "echo 'Should not be run.' && exit 1",
  )

  native.filegroup(
      name = "crosstool",
      srcs = [":CROSSTOOL"],
      output_licenses = ["unencumbered"],
  )
"""

_DUMMY_CROSSTOOL_BUILD_FILE = """
load("//crosstool:error_gpu_disabled.bzl", "error_gpu_disabled")

error_gpu_disabled()
"""

def _create_dummy_repository(
        ctx,
        sycl_libs = None,
        mkl_sycl_libs = None,
        copy_rules = None,
        level_zero_libs = None,
        level_zero_headers = None):
    """
    Create a minimal SYCL layout that intercepts --config=sycl when SYCL
    isn't configured, emitting a clear, actionable error.
    """

    # Normalize optional params
    sycl_libs = sycl_libs or []
    mkl_sycl_libs = mkl_sycl_libs or []
    copy_rules = copy_rules or []
    level_zero_libs = level_zero_libs or []
    level_zero_headers = level_zero_headers or []

    # Intercept attempts to build with --config=sycl when SYCL is not configured.
    ctx.file(
        "error_gpu_disabled.bzl",
        _DUMMY_CROSSTOOL_BZL_FILE,
    )
    ctx.file(
        "BUILD",
        _DUMMY_CROSSTOOL_BUILD_FILE,
    )

    tpl_paths = {labelname: _tpl_path(ctx, labelname) for labelname in [
        ":build_defs.bzl",
        ":BUILD",
    ]}

    # Materialize templated files under sycl/
    ctx.template(
        "sycl/build_defs.bzl",
        tpl_paths[":build_defs.bzl"],
        {
            "%{sycl_is_configured}": "False",
            "%{sycl_build_is_configured}": "False",
        },
    )

    ctx.template(
        "sycl/BUILD",
        tpl_paths[":BUILD"],
        {
            # Dummy placeholders: each expands to full item or "".
            "%{mkl_intel_ilp64_src}": "",
            "%{mkl_sequential_src}": "",
            "%{mkl_core_src}": "",
            "%{mkl_sycl_srcs}": "",

            # Keep these for back-compat.
            "%{mkl_intel_ilp64_lib}": "",
            "%{mkl_sequential_lib}": "",
            "%{mkl_core_lib}": "",
            "%{mkl_sycl_libs}": "",
            "%{level_zero_libs}": "",
            "%{level_zero_headers}": "",
            "%{sycl_headers}": "",
            "%{copy_rules}": "\n".join(copy_rules) if copy_rules else "",
        },
    )

def _buildfile(ctx, build_file):
    """Utility function for writing a BUILD file.

    Args:
      ctx: The repository context of the repository rule calling this utility function.
      build_file: The file to use as the BUILD file for this repository. This attribute is an absolute label.
    """

    ctx.file("BUILD.bazel", ctx.read(build_file))

def _sycl_configure_impl(ctx):
    """Implementation of the sycl_configure rule"""
    if not enable_sycl(ctx):
        _create_dummy_repository(ctx)
        return

    hermetic = ctx.getenv("SYCL_BUILD_HERMETIC") == "1"
    if not hermetic:
        fail("SYCL non-hermetic build hasn't supported")

    tpl_paths = {labelname: _tpl_path(ctx, labelname) for labelname in [
        ":build_defs.bzl",
        ":BUILD",
        "legacy:BUILD.sycl",
        "legacy:sycl_cc_toolchain_config.bzl",
        "legacy:wrappers/crosstool_wrapper_driver_sycl",
        "legacy:wrappers/ar_driver_sycl",
    ]}

    # Set up BUILD file for sycl/
    ctx.template(
        "sycl/build_defs.bzl",
        tpl_paths[":build_defs.bzl"],
        {
            "%{sycl_is_configured}": "True",
            "%{sycl_build_is_configured}": "True",
        },
    )

    ctx.template(
        "sycl/BUILD",
        tpl_paths[":BUILD"],
        {},  # repository_dict,
    )

    ctx.template(
        "BUILD",
        tpl_paths[":BUILD"],
        {},  # repository_dict,
    )

sycl_configure = repository_rule(
    # Detects and configures the local SYCL toolchain.
    # Add the following to your WORKSPACE FILE:
    # ```python
    # sycl_configure(name = "local_config_sycl")
    # ```
    # Args:
    #   name: A unique name for this workspace rule.
    implementation = _sycl_configure_impl,
    local = True,
    attrs = {
        # TODO: Add local paths support
        #"_find_sycl_config": attr.label(default = Label("//gpu/sycl:find_sycl_config.py")),
        #"oneapi_build": attr.label(default = Label("//gpu/sycl/oneapi.BUILD")),
        #"oneapi_level_zero_build": attr.label(default = Label("//gpu/sycl/oneapi_level_zero.BUILD")),
        #"oneapi_zero_loader_build": attr.label(default = Label("//gpu/sycl/oneapi_zero_loader.BUILD")),
        #"oneapi_version": attr.label(default = Label("@oneapi//:version.bzl")),
        #"oneapi_level_zero_version": attr.label(default = Label("@oneapi_level_zero//:version.bzl")),
        #"oneapi_zero_loader_version": attr.label(default = Label("@oneapi_zero_loader//:version.bzl")),
    },
)
