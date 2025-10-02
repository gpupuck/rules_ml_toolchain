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
    if not ver and ctx.attr.default_version:
        ver = ctx.attr.default_version

    if not ver:
        fail("Specify LLVM version in .bazelrc file. Example: --repo_env=LLVM_VERSION=21")

    return ver

def _get_llvm_label(ctx, ver):
    llvm_dict = ctx.attr.versions
    for llvm_label in llvm_dict.keys():
        if llvm_dict[llvm_label] == ver:
            return llvm_label

    return None

def _create_version_file(ctx, major_version):
    ctx.file(
        "version.bzl",
        "VERSION = \"{}\"".format(major_version),
    )

def _llvm_impl(ctx):
    print("_llvm_impl: name =", ctx.attr.name)
    ver = _get_llvm_version(ctx)
    llvm_label = _get_llvm_label(ctx, ver)
    if not llvm_label:
        fail("Add support of LLVM % before use it")

    _create_version_file(ctx, ver)

    ctx.template(
        "BUILD",
        ctx.attr.build_file_tpl,
        {
            "%{llvm_repo_name}": llvm_label.repo_name,
        },
    )

llvm = repository_rule(
    implementation = _llvm_impl,
    attrs = {
        "default_version": attr.string(),
        "versions": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
        ),
        "build_file_tpl": attr.label(mandatory = True),
    },
)
