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

EnableCudaInfo = provider()

def _enable_cuda_flag_impl(ctx):
    value = ctx.build_setting_value
    if ctx.attr.enable_override:
        print(
            "\n\033[1;33mWarning:\033[0m '--define=using_cuda_nvcc' and " +
            "'build:cuda --@local_config_cuda//:enable_cuda' will be " +
            "unsupported soon. Use '--@rules_ml_toolchain//common:enable_cuda' " +
            "instead."
        )
        value = True
    return EnableCudaInfo(value = value)

enable_cuda_flag = rule(
    implementation = _enable_cuda_flag_impl,
    build_setting = config.bool(flag = True),
    attrs = {"enable_override": attr.bool()},
)
