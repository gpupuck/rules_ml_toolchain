licenses(["restricted"])  # NVIDIA proprietary license

cc_library(
    name = "headers",
    hdrs = glob([
        %{comment}"include/cccl/cub/**",
        %{comment}"include/cccl/cuda/**",
        %{comment}"include/cccl/nv/**",
        %{comment}"include/cccl/thrust/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include", "include/cccl"],
    strip_include_prefix = "include/cccl",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
