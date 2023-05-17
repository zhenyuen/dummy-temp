int
main(void)
{
	volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
	
	*gDebugLedsMemoryMappedRegister = 0x00;
	for (int j = 0; j < 400000; j++);
	*gDebugLedsMemoryMappedRegister = 0xFF;
	
	// Benchmark basic logical and arithmetic operations.
	int A = 1062341;
	int B = 2653345;
	int result;
	
	result = A + B; // ADD
	result = A + 1424; // ADDI
	result = A - B; // SUB
	result = A - 1424; // ADDI
	
	result = A >> 2; // SRL
	result = B << 2; // SLL

	result = A & B; // AND
	result = A | B; // OR
	result = A ^ B; // XOR
	result = ~result; // bit-wise complement

	result = A & 1424; // ANDI
	result = A | 1424; // ORI
	result = A ^ B; // XORI
	
	*gDebugLedsMemoryMappedRegister = 0x00;
	return 0;
}
