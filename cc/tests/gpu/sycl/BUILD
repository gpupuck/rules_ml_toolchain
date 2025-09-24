load(
    "@local_config_sycl//sycl:build_defs.bzl",
    "if_sycl_is_configured",
    "sycl_library",
)

sycl_library(
    name = "vector_sycl",
    srcs = ["vector_sycl.cc"],
    hdrs = ["vector_sycl.h"],
    tags = [
        "gpu",
        "oneapi-only",
    ],
)

cc_test(
    name = "vector_sycl_test",
    srcs = [
        "vector_sycl_test.cc",
    ],
    tags = [
        "gpu",
        "oneapi-only",
    ],
    deps = [
        ":vector_sycl",
        "@gtest//:gtest_main",
    ],
)

#############################################
# Test compiler Builtins
cc_test(
    name = "builtins_test",
    srcs = ["builtins_test.cc"],
    deps = [
        "@gtest//:gtest_main",
    ],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":builtins_test",
        ":vector_sycl_test",
    ],
)
