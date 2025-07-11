
def _create_version_file(ctx):
    ctx.file(
        "version.bzl",
        "VERSION = \"\"",
    )

def _llvm_empty_impl(ctx):
    _create_version_file(ctx)

    ctx.file(
        "BUILD",
        content="""
        package(default_visibility = ["//visibility:public"])
        """,
        executable = False,
    )

    return None

llvm_empty = repository_rule(
    implementation = _llvm_empty_impl,
    doc = "Creates an empty external Bazel repository.",
)