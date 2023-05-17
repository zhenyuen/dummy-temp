.PHONY: \
	softwareblink \
	hardwareblink \
	bubblesort \
	clean

softwareblink:
	cd softwareblink; make clean; make; make install
	cd processor; make

hardwareblink:
	cd hardwareblink; make clean; make;

bubblesort:
	cd bubblesort; make clean; make; make install
	cd processor; make

benchmark1:
	cd benchmark1; make clean; make; make install
	cd processor; make

benchmark2:
	cd benchmark2; make clean; make; make install
	cd processor; make

benchmark3:
	cd benchmark3; make clean; make; make install
	cd processor; make

clean:
	cd softwareblink; make clean
	cd hardwareblink; make clean
	cd bubblesort; make clean
	cd processor; make clean
	rm -f build/*.bin
