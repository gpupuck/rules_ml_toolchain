REDIST_DICT = {
    "oneapi": {
        "ubuntu_24.10_2025.1": [
            "https://tensorflow-file-hosting.s3.us-east-1.amazonaws.com/intel-oneapi-base-toolkit-2025.1.3.7.tar.gz",
            "2213104bd122336551aa144512e7ab99e4a84220e77980b5f346edc14ebd458a",
            "oneapi",
        ],
        "ubuntu_24.04_2025.1": [
            "https://tensorflow-file-hosting.s3.us-east-1.amazonaws.com/intel-oneapi-base-toolkit-2025.1.3.7.tar.gz",
            "2213104bd122336551aa144512e7ab99e4a84220e77980b5f346edc14ebd458a",
            "oneapi",
        ],
        "ubuntu_22.04_2025.1": [
            "https://tensorflow-file-hosting.s3.us-east-1.amazonaws.com/intel-oneapi-base-toolkit-2025.1.3.7.tar.gz",
            "2213104bd122336551aa144512e7ab99e4a84220e77980b5f346edc14ebd458a",
            "oneapi",
        ],
    },
    "level_zero": {
        "ubuntu_24.10_2025.1": [
            "https://tensorflow-file-hosting.s3.us-east-1.amazonaws.com/level-zero-1.21.10.tar.gz",
            "e0ff1c6cb9b551019579a2dd35c3a611240c1b60918c75345faf9514142b9c34",
            "",
        ],
    },
    "zero_loader": {
        "ubuntu_24.10_2025.1": [
            "https://tensorflow-file-hosting.s3.us-east-1.amazonaws.com/ze_loader_libs.tar.gz",
            "71cbfd8ac59e1231f013e827ea8efe6cf5da36fad771da2e75e202423bd6b82e",
            "",
        ],
    },
}

BUILD_TEMPLATES = {
    "oneapi": {
        "repo_name": "oneapi",
        "version_to_template": {
            "ubuntu_24.10_2025.1": "//gpu/sycl:oneapi.BUILD",
            "ubuntu_24.04_2025.1": "//gpu/sycl:oneapi.BUILD",
            "ubuntu_22.04_2025.1": "//gpu/sycl:oneapi.BUILD",
        },
    },
    "level_zero": {
        "repo_name": "level_zero",
        "version_to_template": {
            "ubuntu_24.10_2025.1": "//gpu/sycl:level_zero.BUILD",
        },
    },
    "zero_loader": {
        "repo_name": "zero_loader",
        "version_to_template": {
            "ubuntu_24.10_2025.1": "//gpu/sycl:zero_loader.BUILD",
        },
    },
}
