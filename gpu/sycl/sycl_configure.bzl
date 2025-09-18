"""Repository rule for SYCL autoconfiguration.
`sycl_configure` depends on the following environment variables:
  * `TF_NEED_SYCL`: Whether to enable building with SYCL.
  * `GCC_HOST_COMPILER_PATH`: The GCC host compiler path
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "//gpu:tools.bzl",
    "make_copy_dir_rule",
    "make_copy_files_rule",
    "to_list_of_strings",
)
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

def find_cc(ctx):
    """Find the C++ compiler."""

    # Return a dummy value for GCC detection here to avoid error
    if _use_icpx_and_clang(ctx):
        target_cc_name = "clang"
        cc_path_envvar = _CLANG_HOST_COMPILER_PATH
    else:
        target_cc_name = "gcc"
        cc_path_envvar = _GCC_HOST_COMPILER_PATH
    cc_name = target_cc_name
    cc_name_from_env = get_host_environ(ctx, cc_path_envvar)
    if cc_name_from_env:
        cc_name = cc_name_from_env
    if cc_name.startswith("/"):
        # Absolute path, maybe we should make this supported by our which function.
        return cc_name
    cc = which(ctx, cc_name)
    if cc == None:
        fail(("Cannot find {}, either correct your path or set the {}" +
              " environment variable").format(target_cc_name, cc_path_envvar))
    return cc

def find_sycl_root(ctx, sycl_config):
    sycl_name = str(ctx.path(sycl_config.sycl_toolkit_path.strip()).realpath)
    if sycl_name.startswith("/"):
        return sycl_name
    fail("Cannot find DPC++ compiler, please correct your path")

def find_sycl_include_path(ctx, sycl_config):
    """Find DPC++ compiler."""
    base_path = find_sycl_root(ctx, sycl_config)
    bin_path = ctx.path(base_path + "/" + "bin" + "/" + "icpx")
    icpx_extra = ""
    if not bin_path.exists:
        bin_path = ctx.path(base_path + "/" + "bin" + "/" + "compiler" + "/" + "clang")
        if not bin_path.exists:
            fail("Cannot find DPC++ compiler, please correct your path")
    else:
        icpx_extra = "-fsycl"
    if _use_icpx_and_clang(ctx):
        clang_path = ctx.which("clang")
        clang_install_dir = ctx.execute([clang_path, "-print-resource-dir"])
        clang_install_dir_opt = "--sysroot=" + str(ctx.path(clang_install_dir.stdout.strip()).dirname)
        cmd_out = ctx.execute([
            bin_path,
            icpx_extra,
            clang_install_dir_opt,
            "-xc++",
            "-E",
            "-v",
            "/dev/null",
            "-o",
            "/dev/null",
        ])
    else:
        gcc_path = ctx.which("gcc")
        gcc_install_dir = ctx.execute([gcc_path, "-print-libgcc-file-name"])
        gcc_install_dir_opt = "--gcc-install-dir=" + str(ctx.path(gcc_install_dir.stdout.strip()).dirname)
        cmd_out = ctx.execute([
            bin_path,
            icpx_extra,
            gcc_install_dir_opt,
            "-xc++",
            "-E",
            "-v",
            "/dev/null",
            "-o",
            "/dev/null",
        ])

    outlist = cmd_out.stderr.split("\n")
    real_base_path = str(ctx.path(base_path).realpath).strip()
    include_dirs = []
    for l in outlist:
        if l.startswith(" ") and l.strip().startswith("/") and str(ctx.path(l.strip()).realpath) not in include_dirs:
            include_dirs.append(str(ctx.path(l.strip()).realpath))
    return include_dirs

def _lib_name(lib, version = "", static = False):
    """Constructs the name of a library on Linux.

    Args:
      lib: The name of the library, such as "mkl"
      version: The version of the library.
      static: True the library is static or False if it is a shared object.

    Returns:
      The platform-specific name of the library.
    """
    if static:
        return "lib%s.a" % lib
    else:
        if version:
            version = ".%s" % version
        return "lib%s.so%s" % (lib, version)

def _sycl_lib_paths(ctx, lib, basedir):
    file_name = _lib_name(lib, version = "", static = False)
    return [
        ctx.path("%s/%s" % (basedir, file_name)),
    ]

def _batch_files_exist(ctx, libs_paths, bash_bin):
    all_paths = []
    for _, lib_paths in libs_paths:
        for lib_path in lib_paths:
            all_paths.append(lib_path)
    return files_exist(ctx, all_paths, bash_bin)

def _select_sycl_lib_paths(ctx, libs_paths, bash_bin):
    test_results = _batch_files_exist(ctx, libs_paths, bash_bin)

    libs = {}
    i = 0
    for name, lib_paths in libs_paths:
        selected_path = None
        for path in lib_paths:
            if test_results[i] and selected_path == None:
                # For each lib select the first path that exists.
                selected_path = path
            i = i + 1
        if selected_path == None:
            auto_configure_fail("Cannot find sycl library %s in %s" % (name, path))

        libs[name] = struct(file_name = selected_path.basename, path = realpath(ctx, selected_path, bash_bin))

    return libs

def _find_libs(ctx, sycl_config, bash_bin):
    """Returns the SYCL libraries on the system.

    Args:
      ctx: The repository context.
      sycl_config: The SYCL config as returned by _get_sycl_local_config
      bash_bin: the path to the bash interpreter

    Returns:
      Map of library names to structs of filename and path
    """
    mkl_path = _mkl_library_path(sycl_config)
    libs_paths = [
        (name, _sycl_lib_paths(ctx, name, path))
        for name, path in [
            ("mkl_intel_ilp64", mkl_path),
            ("mkl_sequential", mkl_path),
            ("mkl_core", mkl_path),
        ]
    ]
    if sycl_config.sycl_basekit_version_number < "2024":
        libs_paths.append(("mkl_sycl", _sycl_lib_paths(ctx, "mkl_sycl", mkl_path)))
    else:
        libs_paths.append(("mkl_sycl_blas", _sycl_lib_paths(ctx, "mkl_sycl_blas", mkl_path)))
        libs_paths.append(("mkl_sycl_lapack", _sycl_lib_paths(ctx, "mkl_sycl_lapack", mkl_path)))
        libs_paths.append(("mkl_sycl_sparse", _sycl_lib_paths(ctx, "mkl_sycl_sparse", mkl_path)))
        libs_paths.append(("mkl_sycl_dft", _sycl_lib_paths(ctx, "mkl_sycl_dft", mkl_path)))
        libs_paths.append(("mkl_sycl_vm", _sycl_lib_paths(ctx, "mkl_sycl_vm", mkl_path)))
        libs_paths.append(("mkl_sycl_rng", _sycl_lib_paths(ctx, "mkl_sycl_rng", mkl_path)))
        libs_paths.append(("mkl_sycl_stats", _sycl_lib_paths(ctx, "mkl_sycl_stats", mkl_path)))
        libs_paths.append(("mkl_sycl_data_fitting", _sycl_lib_paths(ctx, "mkl_sycl_data_fitting", mkl_path)))
    l0_path = _l0_library_path(sycl_config)
    libs_paths.append(("ze_loader", _sycl_lib_paths(ctx, "ze_loader", l0_path)))
    return _select_sycl_lib_paths(ctx, libs_paths, bash_bin)

def find_sycl_config(ctx):
    """Returns SYCL config dictionary from running find_sycl_config.py"""
    python_bin = get_python_bin(ctx)
    exec_result = execute(ctx, [python_bin, ctx.attr._find_sycl_config])
    if exec_result.return_code:
        auto_configure_fail("Failed to run find_sycl_config.py: %s" % err_out(exec_result))

    # Parse the dict from stdout.
    return dict([tuple(x.split(": ")) for x in exec_result.stdout.splitlines()])

def _get_sycl_local_config(ctx, bash_bin):
    """Detects and returns information about the SYCL installation on the system.

    Args:
      ctx: The repository context.
      bash_bin: the path to the path interpreter
    """
    config = find_sycl_config(ctx)
    sycl_basekit_path = config["sycl_basekit_path"]
    sycl_toolkit_path = config["sycl_toolkit_path"]
    sycl_version_number = config["sycl_version_number"]
    sycl_basekit_version_number = config["sycl_basekit_version_number"]
    mkl_include_dir = config["mkl_include_dir"]
    mkl_library_dir = config["mkl_library_dir"]
    l0_include_dir = config["l0_include_dir"]
    l0_library_dir = config["l0_library_dir"]
    return struct(
        sycl_basekit_path = sycl_basekit_path,
        sycl_toolkit_path = sycl_toolkit_path,
        sycl_version_number = sycl_version_number,
        sycl_basekit_version_number = sycl_basekit_version_number,
        mkl_include_dir = mkl_include_dir,
        mkl_library_dir = mkl_library_dir,
        l0_include_dir = l0_include_dir,
        l0_library_dir = l0_library_dir,
    )

def _tpl_path(ctx, labelname):
    tpl = "//gpu/sycl%s.tpl" if labelname.startswith(":") else "//gpu/sycl/%s.tpl"
    return ctx.path(Label(tpl % labelname))

def _tpl(ctx, tpl, substitutions = {}, out = None):
    if not out:
        out = tpl.replace(":", "/")
    ctx.template(
        out,
        _tpl_path(ctx, tpl),
        substitutions,
    )

_INC_DIR_MARKER_BEGIN = "#include <...>"

def _cxx_inc_convert(path):
    """Convert path returned by cc -E xc++ in a complete path."""
    path = path.strip()
    return path

def _normalize_include_path(ctx, path):
    """Normalizes include paths before writing them to the legacy.

      If path points inside the 'legacy' folder of the repository, a relative
      path is returned.
      If path points outside the 'legacy' folder, an absolute path is returned.
      """
    path = str(ctx.path(path))
    crosstool_folder = str(ctx.path(".").get_child("legacy"))

    if path.startswith(crosstool_folder):
        # We drop the path to "$REPO/crosstool" and a trailing path separator.
        return "\"" + path[len(crosstool_folder) + 1:] + "\""
    return "\"" + path + "\""

def _get_cxx_inc_directories_impl(ctx, cc, lang_is_cpp):
    """Compute the list of default C or C++ include directories."""
    if lang_is_cpp:
        lang = "c++"
    else:
        lang = "c"

    result = raw_exec(ctx, [
        cc,
        "-no-canonical-prefixes",
        "-E",
        "-x" + lang,
        "-",
        "-v",
    ])
    stderr = err_out(result)
    index1 = stderr.find(_INC_DIR_MARKER_BEGIN)
    if index1 == -1:
        return []
    index1 = stderr.find("\n", index1)
    if index1 == -1:
        return []
    index2 = stderr.rfind("\n ")
    if index2 == -1 or index2 < index1:
        return []
    index2 = stderr.find("\n", index2 + 1)
    if index2 == -1:
        inc_dirs = stderr[index1 + 1:]
    else:
        inc_dirs = stderr[index1 + 1:index2].strip()

    return [
        str(ctx.path(_cxx_inc_convert(p)))
        for p in inc_dirs.split("\n")
    ]

def get_cxx_inc_directories(ctx, cc):
    """Compute the list of default C and C++ include directories."""

    # For some reason `clang -xc` sometimes returns include paths that are
    # different from the ones from `clang -xc++`. (Symlink and a dir)
    # So we run the compiler with both `-xc` and `-xc++` and merge resulting lists
    includes_cpp = _get_cxx_inc_directories_impl(ctx, cc, True)
    includes_c = _get_cxx_inc_directories_impl(ctx, cc, False)

    includes_cpp_set = depset(includes_cpp)
    return includes_cpp + [
        inc
        for inc in includes_c
        if inc not in includes_cpp_set.to_list()
    ]

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
        "crosstool/error_gpu_disabled.bzl",
        _DUMMY_CROSSTOOL_BZL_FILE,
    )
    ctx.file(
        "crosstool/BUILD",
        _DUMMY_CROSSTOOL_BUILD_FILE,
    )

    # Materialize templated files under sycl/.
    _tpl(
        ctx,
        ":build_defs.bzl",
        {
            "%{sycl_is_configured}": "False",
            "%{sycl_build_is_configured}": "False",
        },
    )

    _tpl(
        ctx,
        ":BUILD",
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

def _extract_file_name_from_url(url):
    """Extract the file name from a URL by finding the last slash '/'."""
    return url[url.rfind("/") + 1:]

def _download_and_extract_archive(ctx, archive_info, distribution_path, build_file = None):
    """Downloads and extracts a tar.gz ONEAPI redistributable (cached by Bazel)."""

    archive_url = archive_info.get("url")
    print("_download_and_extract_archive: distribution_path=", distribution_path, ", archive_info=", archive_info)

    archive_sha256 = archive_info.get("sha256")
    if not archive_url or not archive_sha256:
        fail("Missing required archive metadata: 'url' or 'sha256'")

    ctx.report_progress("Installing oneAPI Basekit to: %s" % distribution_path)

    archive_override = ctx.getenv("oneAPI_ARCHIVE_OVERRIDE")
    if archive_override:
        ctx.report_progress("Using overridden archive: %s" % archive_override)
        ctx.extract(archive_override, distribution_path)
    else:
        ctx.download_and_extract(
            url = archive_url,
            sha256 = archive_sha256,
            output = distribution_path,
        )

    if build_file:
        _buildfile(ctx, build_file)

    ctx.report_progress("oneAPI Basekit archive extracted and installed.")

def _buildfile(ctx, build_file):
    """Utility function for writing a BUILD file.

    Args:
      ctx: The repository context of the repository rule calling this utility function.
      build_file: The file to use as the BUILD file for this repository. This attribute is an absolute label.
    """

    ctx.file("BUILD.bazel", ctx.read(build_file))

#def _get_repository_urls(dist_info):
#    print("_get_repository_urls: dist_info =")
#
#    # buildifier: disable=function-docstring-return
#    # buildifier: disable=function-docstring-args
#    """Returns a dict of redistribution URLs and their SHA256 values."""
#    url_dict = {}
#    for arch in _REDIST_ARCH_DICT.keys():
#        arch_key = arch
#        if arch_key == "linux-aarch64" and arch_key not in dist_info:
#            arch_key = "linux-sbsa"
#        if arch_key not in dist_info:
#            continue
#        if "relative_path" in dist_info[arch_key]:
#            url_dict[_REDIST_ARCH_DICT[arch]] = [
#                dist_info[arch_key]["relative_path"],
#                dist_info[arch_key].get("sha256", ""),
#            ]
#            continue
#
#        if "full_path" in dist_info[arch_key]:
#            url_dict[_REDIST_ARCH_DICT[arch]] = [
#                dist_info[arch_key]["full_path"],
#                dist_info[arch_key].get("sha256", ""),
#            ]
#            continue
#
#        for cuda_version, data in dist_info[arch_key].items():
#            # CUDNN and NVSHMEM JSON might contain paths for each CUDA version.
#            path_key = "relative_path"
#            if path_key not in data.keys():
#                path_key = "full_path"
#            url_dict["{cuda_version}_{arch}".format(
#                cuda_version = cuda_version,
#                arch = _REDIST_ARCH_DICT[arch],
#            )] = [data[path_key], data.get("sha256", "")]
#    return url_dict

def get_version_and_template_lists(version_to_template):
    # buildifier: disable=function-docstring-return
    # buildifier: disable=function-docstring-args
    """Returns lists of versions and templates provided in the dict."""
    template_to_version_map = {}
    for version, template in version_to_template.items():
        if template not in template_to_version_map.keys():
            template_to_version_map[template] = [version]
        else:
            template_to_version_map[template].append(version)
    version_list = []
    template_list = []
    for template, versions in template_to_version_map.items():
        version_list.append(",".join(versions))
        template_list.append(Label(template))
    return (version_list, template_list)

#def _get_oneapi_version(ctx):
#    return ctx.getenv("ONEAPI_VERSION", "")
#
#def _get_os(ctx):
#    return ctx.getenv("OS", "")
#
#def _get_archive_key(ctx):
#    oneapi_version = _get_oneapi_version(ctx)
#    os_id = _get_os(ctx)
#    if not oneapi_version or not os_id:
#        fail("ONEAPI_VERSION and OS must be set via --repo_env for hermetic build")
#
#    return "{}_{}".format(os_id, oneapi_version)

def _sycl_configure_impl(ctx):
    """Implementation of the sycl_configure rule"""
    if not enable_sycl(ctx):
        _create_dummy_repository(ctx)

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
        "_find_sycl_config": attr.label(default = Label("//gpu/sycl:find_sycl_config.py")),
        "oneapi_build": attr.label(default = Label("//gpu/sycl/oneapi.BUILD")),
        "oneapi_level_zero_build": attr.label(default = Label("//gpu/sycl/oneapi_level_zero.BUILD")),
        "oneapi_zero_loader_build": attr.label(default = Label("//gpu/sycl/oneapi_zero_loader.BUILD")),
        "oneapi_version": attr.label(default = Label("@oneapi//:version.bzl")),
        "oneapi_level_zero_version": attr.label(default = Label("@oneapi_level_zero//:version.bzl")),
        "oneapi_zero_loader_version": attr.label(default = Label("@oneapi_zero_loader//:version.bzl")),
    },
)
