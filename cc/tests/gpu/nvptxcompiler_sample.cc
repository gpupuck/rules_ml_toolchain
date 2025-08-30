#include <nvPTXCompiler.h>
#include <iostream>
#include <vector>
#include <cstring>

const char* ptx_code = R"(
.version 8.3
.target sm_75
.address_size 64

.visible .entry add_kernel(
    .param .u64 a,
    .param .u64 b,
    .param .u64 c
)
{
    .reg .u64 reg_a, reg_b, reg_c_ptr, reg_result;

    // Load the input pointers into registers
    ld.param.u64 reg_a, [a];
    ld.param.u64 reg_b, [b];
    ld.param.u64 reg_c_ptr, [c]; // This is the address where we will store the result

    // Dereference the pointers to get the actual values and add them
    // Note: This assumes a and b point to global memory
    ld.global.u64 reg_a, [reg_a];
    ld.global.u64 reg_b, [reg_b];
    add.u64       reg_result, reg_a, reg_b;

    // Store the result to the global memory location pointed to by c
    st.global.u64 [reg_c_ptr], reg_result;

    ret;
}
)";

int main() {
    std::cout << "PTX compiler test starting..." << std::endl;
    nvPTXCompilerHandle compiler = nullptr;
    nvPTXCompileResult result = nvPTXCompilerCreate(&compiler, strlen(ptx_code), ptx_code);
    if (result != NVPTXCOMPILE_SUCCESS) {
        std::cerr << "Failed to create PTX compiler: " << result << std::endl;
        return 1;
    }

    std::cout << "PTX compiler was created." << std::endl;
    const char* compile_options[] = {"-arch=sm_75"};
    result = nvPTXCompilerCompile(compiler, 1, compile_options);
    if (result != NVPTXCOMPILE_SUCCESS) {
        size_t logSize;
        nvPTXCompilerGetErrorLogSize(compiler, &logSize);
        std::vector<char> log(logSize + 1, 0);
        nvPTXCompilerGetErrorLog(compiler, log.data());
        std::cerr << "PTX compilation failed:\n" << log.data() << std::endl;
        nvPTXCompilerDestroy(&compiler);
        return 2;
    }

    std::cout << "PTX compiler works fine." << std::endl;

    size_t outputSize;
    nvPTXCompilerGetCompiledProgramSize(compiler, &outputSize);
    std::vector<char> cubin(outputSize);
    nvPTXCompilerGetCompiledProgram(compiler, cubin.data());

    std::cout << "PTX compiled to CUBIN (size " << outputSize << " bytes)" << std::endl;

    nvPTXCompilerDestroy(&compiler);
    return 0;
}