"A repository that exposes information about the host platform"

load(":repo_utils.bzl", "repo_utils")

def _impl(rctx):
    # Base BUILD file for this repository
    rctx.file("BUILD.bazel", """# Generated by @aspect_bazel_lib//lib/private:host_repo.bzl
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")    
bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
)
""")

    # defs.bzl file for this repository
    rctx.file("defs.bzl", content = """# Generated by @aspect_bazel_lib//lib/private:host_repo.bzl
# Information about the host platform
host = struct(
    is_darwin = {is_darwin},
    is_linux = {is_linux},
    is_windows = {is_windows},
    os = "{os}",
    platform = "{platform}",
)
""".format(
        is_darwin = repo_utils.is_darwin(rctx),
        is_linux = repo_utils.is_linux(rctx),
        is_windows = repo_utils.is_windows(rctx),
        os = repo_utils.os(rctx),
        platform = repo_utils.platform(rctx),
    ))

host_repo = repository_rule(
    implementation = _impl,
    doc = "Exposes information about the host platform",
)
