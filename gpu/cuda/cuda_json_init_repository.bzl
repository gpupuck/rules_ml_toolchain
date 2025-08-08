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

""" TODO(yuriit): Replace this stub file with a file that has real logic """

load(
    "//third_party/gpus/cuda/hermetic:cuda_json_init_repository.bzl",
    "cuda_json_init_repository_wrapper"
)

load(
    "//third_party/gpus/cuda/hermetic:cuda_redist_versions.bzl",
    "CUDA_REDIST_JSON_DICT",
    "CUDNN_REDIST_JSON_DICT",
    "MIRRORED_TARS_CUDA_REDIST_JSON_DICT",
    "MIRRORED_TARS_CUDNN_REDIST_JSON_DICT",
)

def cuda_json_init_repository(
        cuda_json_dict = CUDA_REDIST_JSON_DICT,
        cudnn_json_dict = CUDNN_REDIST_JSON_DICT,
        mirrored_tars_cuda_json_dict = MIRRORED_TARS_CUDA_REDIST_JSON_DICT,
        mirrored_tars_cudnn_json_dict = MIRRORED_TARS_CUDNN_REDIST_JSON_DICT):
    cuda_json_init_repository_wrapper(cuda_json_dict, cudnn_json_dict, mirrored_tars_cuda_json_dict, mirrored_tars_cudnn_json_dict)