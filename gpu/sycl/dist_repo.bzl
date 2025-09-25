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

def _get_file_name(url):
    last_slash_index = url.rfind("/")
    return url[last_slash_index + 1:]

def _download_distribution(ctx, dist):
    # buildifier: disable=function-docstring-args
    """Downloads and extracts Intel distribution."""

    url = dist[0]
    file_name = _get_file_name(url)
    print("Downloading {}".format(url))  # buildifier: disable=print
    ctx.download(
        url = url,
        output = file_name,
        sha256 = dist[1],
    )

    strip_prefix = dist[2]

    print("Extracting {} with strip prefix '{}'".format(file_name, strip_prefix))  # buildifier: disable=print
    ctx.extract(
        archive = file_name,
        stripPrefix = strip_prefix,
    )

    ctx.delete(file_name)

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

def _handle_level_zero(ctx):
    # Symlink for includes backward compatibility (example: #include <level_zero/ze_api.h>)
    ctx.symlink("include", "level_zero")

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

    if ctx.name == "level_zero":
        _handle_level_zero(ctx)

    build_template = ctx.attr.build_templates[dist_key]
    _build_file(ctx, Label(build_template))

def _dist_repo_impl(ctx):
    local_dist_path = None
    if local_dist_path:
        # TODO: Implement SYCL non-hermetic build
        fail("SYCL non-hermetic build hasn't supported")

    else:
        _use_downloaded_archive(ctx)

dist_repo = repository_rule(
    implementation = _dist_repo_impl,
    attrs = {
        "distrs": attr.string_list_dict(mandatory = True),
        "build_templates": attr.string_dict(mandatory = True),
    },
)
