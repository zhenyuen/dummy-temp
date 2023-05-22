int main(void) {
    volatile unsigned int *gDebugLedsMemoryMappedRegister =
        (unsigned int *)0x2000;
    // volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int
    // *)0x8000000;

    *gDebugLedsMemoryMappedRegister = 0x00;
    for (int j = 0; j < 400000; j++)
        ;
    *gDebugLedsMemoryMappedRegister = 0xFF;

	int A = 1062;
    int B = -634;
    int result = 0;
    for (int j = 0; j < 5000000; j++) {  // For loop to increase execution time.
        // Benchmark basic logical and arithmetic operations.
        result = j + j + A;     // ADD
    }
    result = 1696 + B;
    
    while (result != A) *gDebugLedsMemoryMappedRegister = 0x00;

    *gDebugLedsMemoryMappedRegister = 0x00;
    return 0;
}
