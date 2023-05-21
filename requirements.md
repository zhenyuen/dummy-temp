available hardware
- SPRAM (4 blocks, each 128 kB, 16 bits in width) as cache
- 5000 flip flops, relatively less


applications
- Circuit Python (SPI PSRAM on bitsy)
- Linux ( iCEbreaker + Quad HyperRAM PMOD)


specifications
- For a 32 bit data bus, need two SPRAM, so even number of SPRAM required
- Total capacity either 64K or 128k
- Set associate cache : 2 or 4 ways
    - Will be shared by data and instructions
    - At least 2 ways, but if more resource available, then increase to 4
- 64b or 128b cache lines
    - use 64b:  HR -> 16 cycle burst, SPI -> 32 cycle burst
    - 128b: HR -> 16 cycle burst, SPI -> 64 cycle burst
- store metadata in block RAM
    - several modes, but only useful one is 16 bit data bus, 8 bit address
    

calculations
- 4 bit word id -> 16 words per cache line -> 64 bytes per cache line

thingstodo
- calculate the number of clock cycles needed to fetch a memory block to cache

spibasics
- single byte: one byte at a time
- burst mode: several bytes in a single transfer sequence



cachememorybasics
- levels: registers -> cache (associative addressing) -> main memory (RAM) -> long term storage
- terms
    - miss: element not found at that particular memory level
    - hit: found element
    - locality of reference (principle of locality):
        - (temporal locality) once accesed, data will be used again soon
        - (spatial locality) neighbours will also be used soon
        - (sequential locality) data in sequence together will be used soon
    - thrashing
        - bringing something in and throwing it out again repeatedly.
- hardware
    - full address: || block  id | word id ||
    - bring in all memory with same block id
    - if word id is n bit, then 2^n memory address brought in.
    - the larger the word id:
        - the larger the memory block brought in
        - miss rate increases as memory address far apart
        - longer time to bring in large memory block
    - how data stored in cache
        - || tag | cache line ||
        - tag identifies where the data originates from (memory address in main memory)
        - tag is related to the block id by some algorithm
        - each cache line stores 2^n data (n is word id bit length)
- fully associative addressing
    - full address: || block  id | word id [n] ||
    - a block can be stored in any cache line
    - block id used as tag
    - the cache hardware finds block id from available tags in cache instantaneously
    - imagine cache as 2D array, block id is the row index, word is it the column index
    - if data not in cache, have to evict
    - eviction policies
        - FIFO: replace block thats been in cache the longest (queue)
            - Bad for OS routines / syscalls
        - LRU: replace least recently used
            - Best
        - LFU: replace least frequency used
        - Random
            - Cheap and low power, less metadata required, good for small devices
    - Pros: Least chance of trashing among other addressing methods
    - Cons: Expensive, slow
- direct mapping addressing
    - full address: || block  id | line id [m] | word id [n] ||
    - 2^m cache lines
    - Each cache line has an associated line id in addition to tag
    - Each block can be stored in only ONE cache line
    - Pros: Fast look ups, cheap
    - Cons:
        - Thrashing, the same cache line can be occupied while others stay idle
        - Occus when block address have same line id
        - Same cache line being constantly evict / write to
        - To reduce, add more cache lines
- set associative addressing - denoted as K way set associative
    - balance between full associative and direct mapped
    - full address: || block  id | set id [m] | word id [n] ||
    - each set id correspond to a group of cache lines 
    - K * 2^m cache lines, k is "load factor"
    - each block can be stored in any K cache lines
    - basically direct mapping with multiple sets of full associative cache lines.
    - eviction policy applies to each set
    - can reduce thrashing by increasing K
- each cache line has its own flags / metadata
    - type, T: data or instruction
    - valid, V: whether the line contains valid elements. At start up, all lines should be marked invalid
    - lock, L: lock the line to prevent eviction / replacement
        - For set associative, if all lines in a set is locked, we unlock the first line by default
    - dirty, D: identifies a line of data that has been written to but not updated in main memory
    - age: indicate number of cycles since last used (for LRU)
- write policies
    - write through: ignore D flag, every write to the cache also writes to main memory
        - useful if data is shared between multiple processors
        - increased bus traffic
    - write back: update main memory only when a dirty line is to be replaced
    - (advance) write through with bus watching
- typically the data and instruction cache are separated on lower levels, but shared on higher levels
    - E.g., L1 (split), L2 (shared / unified)
    - Instruction and data cache has different requirements
        - E.g., instruction cache does not require write updates (instructions wont be updated like data)



- metrics
    - hit rate = fraction of times that element was found = hit / (miss + hit)
    - effective access time = (hit rate * cache access time) + (miss rate * main memory access time)
- instruction in main memory, so there is unavoidable misses at start up
- 

