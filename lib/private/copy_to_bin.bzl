# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Implementation of copy_to_bin macro and underlying rules."""

load(":copy_file.bzl", "copy_file_action")

def _impl(ctx):
    all_dst = []
    for src in ctx.files.srcs:
        if not src.is_source:
            fail("A source file must be specified in copy_to_bin rule, %s is not a source file." % src.path)
        dst = ctx.actions.declare_file(src.basename, sibling = src)
        copy_file_action(ctx, src, dst, is_windows = ctx.attr.is_windows)
        all_dst.append(dst)
    return DefaultInfo(
        files = depset(all_dst),
        runfiles = ctx.runfiles(files = all_dst),
    )

_copy_to_bin = rule(
    implementation = _impl,
    provides = [DefaultInfo],
    attrs = {
        "is_windows": attr.bool(mandatory = True),
        "srcs": attr.label_list(mandatory = True, allow_files = True),
    },
)

def copy_to_bin(name, srcs, **kwargs):
    """Copies a source file to output tree at the same workspace-relative path.

    e.g. `<execroot>/path/to/file -> <execroot>/bazel-out/<platform>/bin/path/to/file`

    This is useful to populate the output folder with all files needed at runtime, even
    those which aren't outputs of a Bazel rule.

    This way you can run a binary in the output folder (execroot or runfiles_root)
    without that program needing to rely on a runfiles helper library or be aware that
    files are divided between the source tree and the output tree.

    Args:
        name: Name of the rule.
        srcs: A list of labels. File(s) to copy.
        **kwargs: further keyword arguments, e.g. `visibility`
    """
    _copy_to_bin(
        name = name,
        srcs = srcs,
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs
    )
