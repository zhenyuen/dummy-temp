int
main(void)
{
	volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;

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

	return 0;
}
