all:
	nvcc -o pmonitor -O3 pmonitor.c utilities.c jnano_pow.c jnano_rate.c measurement_threads.c monitoring.c gpu_counter_access.cu -lcusparse -li2c 

	
clean: 
	rm pmonitor
