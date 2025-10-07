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
    "//third_party/remote_config:common.bzl",
    "get_host_environ",
)

_SYSROOT = "SYSROOT"

def _get_platform_arch(ctx):
    """Gets current platform architecture"""
    if ctx.os.arch == "amd64":
        return "x86_64"
    else:
        return ctx.os.arch

def _is_compatible_arch(ctx):
    """Checks if SYSROOT compatible with current platform"""
    return _get_platform_arch(ctx) in ctx.attr.name

def _get_sysroot_version_flag(ctx):
    """Returns SYSROOT version put as environment variable"""
    return get_host_environ(ctx, _SYSROOT)

def _get_sysroot_version(ctx):
    """Returns the SYSROOT version from the SYSROOT repository environment variable, defaulting otherwise"""
    ver = _get_sysroot_version_flag(ctx) or ctx.attr.default_version

    if not ver:
        fail("Specify SYSROOT version in .bazelrc file. Example: --repo_env=SYSROOT=manylinux_2_31")

    return ver

def _get_sysroot_label(ctx, ver):
    """Returns the SYSROOT label for the specified version"""
    sysroot_dict = ctx.attr.versions
    for sysroot_label in sysroot_dict.keys():
        if sysroot_dict[sysroot_label] == ver:
            return sysroot_label

    return None

def _sysroot_impl(ctx):
    if not _is_compatible_arch(ctx):
        ctx.file("BUILD", "")
        return

    ver = _get_sysroot_version(ctx)
    sysroot_label = _get_sysroot_label(ctx, ver)
    if not sysroot_label:
        fail("Ensure SYSROOT {} support is added prior to use. Supported versions: {}"
            .format(ver, ", ".join(ctx.attr.versions.values())))

    ctx.template(
        "BUILD",
        ctx.attr.build_file_tpl,
        {
            "%{sysroot_repo_name}": sysroot_label.repo_name,
        },
    )

sysroot = repository_rule(
    implementation = _sysroot_impl,
    attrs = {
        "default_version": attr.string(),
        "versions": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
        ),
        "build_file_tpl": attr.label(mandatory = True),
    },
)
