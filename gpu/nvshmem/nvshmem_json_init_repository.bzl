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
    "//third_party/nvshmem/hermetic:nvshmem_json_init_repository.bzl",
    "nvshmem_json_init_repository_wrapper",
)

load(
    "//third_party/gpus/cuda/hermetic:cuda_redist_versions.bzl",
    "MIRRORED_TARS_NVSHMEM_REDIST_JSON_DICT",
    "NVSHMEM_REDIST_JSON_DICT",
)

def nvshmem_json_init_repository(
        nvshmem_json_dict = NVSHMEM_REDIST_JSON_DICT,
        mirrored_tars_nvshmem_json_dict = MIRRORED_TARS_NVSHMEM_REDIST_JSON_DICT):
    nvshmem_json_init_repository_wrapper(nvshmem_json_dict, mirrored_tars_nvshmem_json_dict)
