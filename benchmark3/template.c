int f1(int A, int B) {
	int result;
	
	result = A + B; // ADD
	result = A + 1424; // ADDI
	result = A - B; // SUB
	result = A - 1424; // ADDI

	return result;
}

int f2(int A, int B) {
	int result = f1(A, B); // recursive calls to trigger stack pointer
	
	result = A >> 2; // SRL
	result = B << 2; // SLL

	result = A & B; // AND
	result = A | B; // OR
	result = A ^ B; // XOR
	result = ~result; // bit-wise complement

	result = A & 1424; // ANDI
	result = A | 1424; // ORI
	result = A ^ B; // XORI
	
	return result;
}

int
main(void)
{
	int A = 1062341;
	int B = 2653345;
	int result = 0;
	for (int i = 0; i < 100; i++) {
		result += i;
		if (i % 2 == 0) { // If conditions for branching.
			result = f1(A, B);
		} else {
			result = f2(A, B);
		}
	}
	return 0;
}

