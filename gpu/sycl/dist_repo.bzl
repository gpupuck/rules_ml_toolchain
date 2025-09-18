load("//third_party:repo.bzl", "tf_mirror_urls")

_SUPPORTED_ARCHIVE_EXTENSIONS = [
    ".zip",
    ".jar",
    ".war",
    ".aar",
    ".tar",
    ".tar.gz",
    ".tgz",
    ".tar.xz",
    ".txz",
    ".tar.zst",
    ".tzst",
    ".tar.bz2",
    ".tbz",
    ".ar",
    ".deb",
    ".whl",
]

_TEGRA = "tegra"

OS_ARCH_DICT = {
    "amd64": "x86_64-unknown-linux-gnu",
    "aarch64": "aarch64-unknown-linux-gnu",
    "tegra-aarch64": "tegra-aarch64-unknown-linux-gnu",
}

def _get_env_var(ctx, name):
    return ctx.getenv(name)

def create_dummy_build_file(ctx, use_comment_symbols = True):
    ctx.template(
        "BUILD",
        ctx.attr.build_templates[0],
        {
            "%{multiline_comment}": "'''" if use_comment_symbols else "",
            "%{comment}": "#" if use_comment_symbols else "",
        },
    )

def create_cuda_nvcc_build_file(ctx, use_comment_symbols = True):
    cuda_version = (_get_env_var(ctx, "HERMETIC_CUDA_VERSION") or
                    _get_env_var(ctx, "TF_CUDA_VERSION"))
    ctx.template(
        "BUILD",
        ctx.attr.build_templates[0],
        {
            "%{multiline_comment}": "'''" if use_comment_symbols else "",
            "%{comment}": "#" if use_comment_symbols else "",
            "%{version_of_cuda}": cuda_version,
        },
    )

def _get_build_template(ctx, major_lib_version):
    template = None
    for i in range(0, len(ctx.attr.versions)):
        for dist_version in ctx.attr.versions[i].split(","):
            if dist_version == major_lib_version:
                template = ctx.attr.build_templates[i]
                break
    if not template:
        fail("No build template found for {} version {}".format(
            ctx.name,
            major_lib_version,
        ))
    return template

def create_build_file(
        ctx,
        lib_name_to_version_dict,
        major_lib_version):
    # buildifier: disable=function-docstring-args
    """Creates a BUILD file for the repository."""
    if len(major_lib_version) == 0:
        build_template_content = ctx.read(
            ctx.attr.build_templates[0],
        )

        if ctx.name == "cuda_nvcc":
            create_cuda_nvcc_build_file(
                ctx,
                use_comment_symbols = True if "_version}" in build_template_content else False,
            )
        else:
            create_dummy_build_file(
                ctx,
                use_comment_symbols = True if "_version}" in build_template_content else False,
            )

        return
    build_template = _get_build_template(
        ctx,
        major_lib_version.split(".")[0],
    )
    ctx.template(
        "BUILD",
        build_template,
        lib_name_to_version_dict | {
            "%{multiline_comment}": "",
            "%{comment}": "",
        },
    )

def _create_symlinks(ctx, local_path, dirs):
    for dir in dirs:
        dir_path = "{path}/{dir}".format(
            path = local_path,
            dir = dir,
        )
        if not ctx.path(local_path).exists:
            fail("%s directory doesn't exist!" % dir_path)
        ctx.symlink(dir_path, dir)

def _create_libcuda_symlinks(
        ctx,
        lib_name_to_version_dict):
    lib_names = ["cuda", "nvidia-ml", "nvidia-ptxjitcompiler"]
    if ctx.name == "cuda_driver":
        for lib in lib_names:
            key = "%" + "{lib%s_version}" % lib
            if key not in lib_name_to_version_dict:
                return
            versioned_lib_path = "lib/lib{}.so.{}".format(
                lib,
                lib_name_to_version_dict[key],
            )
            if not ctx.path(versioned_lib_path).exists:
                fail("%s doesn't exist!" % versioned_lib_path)
            symlink_so_1 = "lib/lib%s.so.1" % lib
            if ctx.path(symlink_so_1).exists:
                print("File %s already exists!" % ctx.path(symlink_so_1))  # buildifier: disable=print
            else:
                ctx.symlink(versioned_lib_path, symlink_so_1)
            unversioned_symlink = "lib/lib%s.so" % lib
            if ctx.path(unversioned_symlink).exists:
                print("File %s already exists!" % ctx.path(unversioned_symlink))  # buildifier: disable=print
            else:
                ctx.symlink(symlink_so_1, unversioned_symlink)

def _create_repository_symlinks(ctx):
    for target, link_name in ctx.attr.repository_symlinks.items():
        target_path = ctx.path(target)
        if not target_path.exists:
            print("Target %s doesn't exist!" % target_path)  # buildifier: disable=print
            continue
        if ctx.path(link_name).exists:
            print("File %s already exists!" % ctx.path(link_name))  # buildifier: disable=print
            continue
        ctx.symlink(target_path, link_name)

def create_version_file(ctx, major_lib_version):
    ctx.file(
        "version.bzl",
        "VERSION = \"{}\"".format(major_lib_version),
    )

def use_local_redist_path(ctx, local_redist_path, dirs):
    # buildifier: disable=function-docstring-args
    """Creates repository using local redistribution paths."""
    _create_symlinks(
        ctx,
        local_redist_path,
        dirs,
    )

    lib_name_to_version_dict = "get_lib_name_to_version_dict(ctx)"  # TODO: Replace
    major_version = ""
    create_build_file(
        ctx,
        lib_name_to_version_dict,
        major_version,
    )
    _create_libcuda_symlinks(
        ctx,
        lib_name_to_version_dict,
    )
    create_version_file(ctx, major_version)

def get_archive_name(url):
    # buildifier: disable=function-docstring-return
    # buildifier: disable=function-docstring-args
    """Returns the archive name without extension."""
    filename = _get_file_name(url)
    for extension in _SUPPORTED_ARCHIVE_EXTENSIONS:
        if filename.endswith(extension):
            return filename[:-len(extension)]
    return filename

def _get_file_name(url):
    last_slash_index = url.rfind("/")
    return url[last_slash_index + 1:]

def _download_distribution(ctx, dist):
    # buildifier: disable=function-docstring-args
    """Downloads and extracts Intel distribution."""

    # If url is not relative, then appending prefix is not needed.
    #    if not (url.startswith("http") or url.startswith("file:///")):
    #        if url.endswith(".tar"):
    #            url = mirrored_tar_path_prefix + url
    #        else:
    #            url = path_prefix + url
    #    archive_name = get_archive_name(url)
    #    file_name = _get_file_name(url)
    #    urls = [url] if url.endswith(".tar") else tf_mirror_urls(url)

    url = dist[0]
    file_name = _get_file_name(url)
    print("Downloading {}".format(url))  # buildifier: disable=print
    ctx.download(
        url = url,
        output = file_name,
        sha256 = dist[1],
    )

    #if ctx.attr.override_strip_prefix:
    #    strip_prefix = ctx.attr.override_strip_prefix

    strip_prefix = dist[2]

    print("Extracting {} with strip prefix '{}'".format(file_name, strip_prefix))  # buildifier: disable=print
    ctx.extract(
        archive = file_name,
        stripPrefix = strip_prefix,
    )

    ctx.delete(file_name)

def _get_platform_architecture(ctx):
    # buildifier: disable=function-docstring-return
    # buildifier: disable=function-docstring-args
    """Returns the platform architecture for the redistribution."""
    target_arch = _get_env_var(ctx, ctx.attr.target_arch_env_var)

    # We use NVCC compiler as the host compiler.
    if target_arch and ctx.name != "cuda_nvcc":
        if target_arch in OS_ARCH_DICT.keys():
            host_arch = target_arch
        else:
            fail(
                "Unsupported architecture: {arch}, use one of {supported}".format(
                    arch = target_arch,
                    supported = OS_ARCH_DICT.keys(),
                ),
            )
    else:
        host_arch = ctx.os.arch

    if host_arch == "aarch64":
        uname_result = ctx.execute(["uname", "-a"]).stdout
        if _TEGRA in uname_result:
            return "{}-{}".format(_TEGRA, host_arch)
    return host_arch

def _get_oneapi_version(ctx):
    return ctx.getenv("ONEAPI_VERSION", "")

def _get_os(ctx):
    return ctx.getenv("OS", "")

def _get_dist_key(ctx):
    oneapi_version = _get_oneapi_version(ctx)
    os_id = _get_os(ctx)
    if not oneapi_version or not os_id:
        fail("ONEAPI_VERSION and OS must be set via --repo_env for hermetic build")

    return "{}_{}".format(os_id, oneapi_version)

def _build_file(ctx, build_file):
    """Utility function for writing a BUILD file.

    Args:
      ctx: The repository context of the repository rule calling this utility function.
      build_file: The file to use as the BUILD file for this repository. This attribute is an absolute label.
    """

    print("_build_file: build_file =", build_file)
    ctx.file("BUILD.bazel", ctx.read(build_file))

def _use_downloaded_archive(ctx):
    # buildifier: disable=function-docstring-args
    """ Downloads redistribution and initializes hermetic repository."""
    dist_key = _get_dist_key(ctx)

    dist = ctx.attr.distrs[dist_key]

    if not dist:
        fail(
            ("Version {version} for platform {platform} is not supported.")
                .format(version = _get_oneapi_version(ctx), platform = _get_os(ctx)),
        )

    _download_distribution(ctx, dist)

    #if not dist or not build_template:
    # If no toolkit version is found, comment out cc_import targets.
    # TODO: Create dummy build files
    #create_dummy_build_file(ctx)
    #create_version_file(ctx, major_version)
    #    return

    #lib_name_to_version_dict = "get_lib_name_to_version_dict(ctx)"
    build_template = ctx.attr.build_templates[dist_key]
    _build_file(ctx, Label(build_template))

    #_create_repository_symlinks(ctx)
    #create_version_file(ctx, major_version)

def _dist_repo_impl(ctx):
    #print("_dist_repo_impl: name = \"{}\"".format(ctx.name))
    local_dist_path = None  #_get_env_var(ctx, ctx.attr.local_path_env_var)
    if local_dist_path:
        #use_local_dist_path(ctx, local_dist_path, ctx.attr.local_source_dirs)
        fail("SYCL non-hermetic build hasn't supported")
        # TODO: Implement SYCL non-hermetic build

    else:
        _use_downloaded_archive(ctx)

dist_repo = repository_rule(
    implementation = _dist_repo_impl,
    attrs = {
        #"urls": attr.string_list(mandatory = True),
        #"sha256": attr.string(mandatory = False),
        #"strip_prefix": attr.string(),
        #"build_file": attr.label(),
        #"version": attr.string_list(),
        "distrs": attr.string_list_dict(mandatory = True),
        "build_templates": attr.string_dict(mandatory = True),
        #"versions": attr.string_list(mandatory = True),
        #"override_strip_prefix": attr.string(),
        #"redist_path_prefix": attr.string(),
        #"mirrored_tar_redist_path_prefix": attr.string(mandatory = False),
        #"local_path_env_var": attr.string(mandatory = True),
        #"use_tar_file_env_var": attr.string(mandatory = True),
        #"target_arch_env_var": attr.string(mandatory = True),
        #"local_source_dirs": attr.string_list(mandatory = False),
        #"repository_symlinks": attr.label_keyed_string_dict(mandatory = False),
    },
)
