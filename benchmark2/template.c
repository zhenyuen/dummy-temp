int
main(void)
{
	// Benchmark more complex logical and arithmetic operations.
	int A = 1062;
	float B = 2653;
	int result;
	float fpresult;
	
	result = A * B; // integer multiplication
	fpresult = result * B; // floating point multiplication
	fpresult = A / B; // floating point division
	fpresult = 12 * fpresult; // fp multiplication with immediate

	return 0;
}
