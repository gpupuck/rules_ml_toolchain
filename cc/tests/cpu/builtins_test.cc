//
// Created by yuriit on 9/19/25.
//

#include "gtest/gtest.h"
#include <algorithm> // For std::max

// Test suite for standard library algorithms
TEST(StandardAlgorithmsTest, MaxFunction) {
    EXPECT_EQ(std::max(5, 10), 10);
    EXPECT_EQ(std::max(-5, -10), -5);
    EXPECT_EQ(std::max(7, 7), 7);
}

//BuiltinsTest
// Test suite for compiler intrinsics (example with __builtin_clz)
TEST(CompilerIntrinsicsTest, BuiltinClz) {
    EXPECT_EQ(__builtin_clz(1), 31); // Assuming 32-bit int
    EXPECT_EQ(__builtin_clz(8), 28); // Assuming 32-bit int
}
