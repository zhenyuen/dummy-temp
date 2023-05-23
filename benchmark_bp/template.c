// #include <stdio.h>

#define ARRAY_SIZE 10000

int main() {
	volatile unsigned int *gDebugLedsMemoryMappedRegister =
	(unsigned int *)0x2000;
	// volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int
	// *)0x8000000;

    *gDebugLedsMemoryMappedRegister = 0x00;
    for (int j = 0; j < 400000; j++);

    *gDebugLedsMemoryMappedRegister = 0xFF;

    int branch_history[ARRAY_SIZE];
    int branch_targets[ARRAY_SIZE];
    int predicted_targets[ARRAY_SIZE];
    
    // Initialize branch history, branch targets, and predicted targets arrays
    for (int i = 0; i < ARRAY_SIZE; i++) {
        branch_history[i] = i % 2;  // Alternate taken and not taken branches
        branch_targets[i] = i + 1;  // Predict next instruction address
        predicted_targets[i] = 0;   // Initially, predicted target is 0
    }
    
    int correct_predictions = 0;
    
    // Simulate branch prediction and calculate accuracy
    for (int i = 0; i < ARRAY_SIZE; i++) {
        if (predicted_targets[i] == branch_targets[i]) {
            correct_predictions++;
        }
        
        // Update predicted target based on branch history
        if (branch_history[i] == 1) {
            predicted_targets[i] = i + 1;  // Predict next instruction address
        } else {
            predicted_targets[i] = i + 2;  // Predict next-next instruction address
        }
    }
    
    // double accuracy = (double)correct_predictions / ARRAY_SIZE * 100.0;
    // printf("Branch prediction accuracy: %.2f%%\n", accuracy);
    
	*gDebugLedsMemoryMappedRegister = 0x00;
    return 0;
}
