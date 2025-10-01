def _llvm_impl(ctx):
    ctx.template(
        "BUILD",
        ctx.attr.llvm_linux_x86_64_build_tpl,
        {
            "%{llvmX}": "",
        },
    )

    ctx.file("version.bzl", ctx.read(Label("//cc/llvm:version.bzl")))
    ctx.file("BUILD", ctx.read(Label("//cc/llvm:llvm_linux_x86_64.BUILD")))

llvm = repository_rule(
    implementation = _llvm_impl,
    attrs = {
        "default_version": attr.string(mandatory = True),
        "versions": attr.string_dict(mandatory = True),
        "llvm_linux_x86_64_build_tpl": attr.label(default = Label("//cc/llvm:llvm_linux_x86_64.BUILD.tpl")),
        "llvm_linux_aarch64_build_tpl": attr.label(default = Label("//cc/llvm:llvm_linux_aarch64.BUILD.tpl")),
    },
)
