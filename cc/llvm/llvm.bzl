load(
    "//third_party/remote_config:common.bzl",
    "get_host_environ",
)

_LLVM_VERSION = "LLVM_VERSION"

def _get_llvm_version_flag(ctx):
    """Returns LLVM version put as environment variable"""
    return get_host_environ(ctx, _LLVM_VERSION)

def _get_llvm_version(ctx):
    ver = _get_llvm_version_flag(ctx)
    if not ver:
        ver = ctx.attr.default_version

    return ver

def _create_version_file(ctx, major_version):
    ctx.file(
        "version.bzl",
        "VERSION = \"{}\"".format(major_version),
    )

def _llvm_impl(ctx):
    ver = _get_llvm_version(ctx)
    real_label = ctx.attr.versions[ver]
    if not real_label:
        fail("Add support of LLVM % before use it")

    _create_version_file(ctx, ver)

    ctx.template(
        "BUILD",
        ctx.attr.build_file_tpl,
        {
            "%{llvmX}": real_label,
        },
    )

llvm = repository_rule(
    implementation = _llvm_impl,
    attrs = {
        "default_version": attr.string(mandatory = True),
        "versions": attr.string_dict(mandatory = True),
        "build_file_tpl": attr.label(mandatory = True),
    },
)
