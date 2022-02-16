/*******************************************************************************
--------------------------------------------------------------------------------

	File		: 	measurement_threads.c

	Date		: 	15/02/2022
		
	Author		:	Matthew Burgess, building on the work of Deepthi Nanduri and Dr Jose Nunez-Janez
		
	Description	:	File containting all essential functions to read physical sensors and performance counters from GPU
				PMU counters and launching threads in parallel to launch BM programs. 
				This script is adopted from work of Nunez-Yanez et al
				This file will be used in conjunction with the top file pmonitor.c
							
----------------------------------------------------------------------------------
**********************************************************************************/

#define _GNU_SOURCE
#ifndef __USE_GNU
#define __USE_GNU
#endif
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
#include <unistd.h>
#include <string.h>
#include "jnano_inst.h"
#include "monitoring.h"

extern int pc;

int start;
pthread_mutex_t mutex;

int stop;
pthread_t  thread_ID;
void      *exit_status;
struct jetsonnano_sample * head;

long long int sample_count = 0;
unsigned int gpu_power_total = 0;

void *jetsonnano_read_samples(void *head) {

	FILE *fp_log;
	int gpu_power_value;

	int start_flag = 0;
	int stop_flag = 0;
	fp_log = fopen("power_measurement_log.txt", "a");
	if (!fp_log) {
		printf("cannot open power_measurement_log.txt file \n ");
		return 0;
	}

	while(1) {

		start_flag = 1;
		pthread_mutex_lock(&mutex);
		if(start == 0)
			start_flag = 0;
		pthread_mutex_unlock(&mutex);
		if(start_flag == 0)
			continue;

		jnano_get_ina3221(VDD_GPU, POWER,  &gpu_power_value);

		gpu_power_total    += gpu_power_value;

		sample_count++;

		stop_flag = 0;
		pthread_mutex_lock(&mutex);
		if (stop == 1) {
			stop_flag = 1;
		}
		pthread_mutex_unlock(&mutex);

		if(stop_flag==1) {
			break;
		}
	}
	fclose(fp_log);
	return 0;
}

void *jetsonnano_read_sample_pthread() {

	pthread_mutex_init(&mutex, NULL);

	pthread_mutex_lock(&mutex);
	stop = 0;
	start = 0;
	pthread_mutex_unlock(&mutex);

	head = (struct jetsonnano_sample *)malloc(sizeof (struct jetsonnano_sample));
	head->next = NULL;

	pthread_create(&thread_ID, NULL, jetsonnano_read_samples, head);

	return head;
}


void jetsonnano_read_sample_start( ) {

	pthread_mutex_lock(&mutex);
	start = 1;
	stop  = 0;
	pthread_mutex_unlock(&mutex);
}


void jetsonnano_read_sample_stop( ) {

	pthread_mutex_lock(&mutex);
	stop = 1;
	start = 0;
	pthread_mutex_unlock(&mutex);
	pthread_join(thread_ID, &exit_status);
	pthread_detach(thread_ID);
}

void jetsonnano_clear_sample_pthread(struct jetsonnano_sample *head) {
	
	struct jetsonnano_sample *sample = head;
	while (sample != (struct jetsonnano_sample *)NULL)
		{
			struct jetsonnano_sample *next = sample->next;
			free (sample);
			sample = next;
		}
	pthread_mutex_destroy(&mutex);
}

void data_retrieval_particlefilter(){
	printf("\n\t-------------------ENTERING data_retrieval_particlefilter-------------------\n");

	char gpu_freq[100];
	char gpu_temp[100];
	char gpu_voltage[100];
	char gpu_power[100];

	struct timespec tsample = {0,0};
	float timenow, starttime;
			
	FILE *rate = fopen("/sys/kernel/debug/clk/override.gbus/clk_rate","r");					// add path to the sysfs file to read GPU clock
	FILE *voltage = fopen("/sys/bus/i2c/drivers/ina3221x/6-0040/iio:device0/in_voltage1_input","r");	// add path to the sysfs file to read GPU voltage
	FILE *temp = fopen("/sys/devices/virtual/thermal/thermal_zone5/temp","r");				// add path to the sysfs file to read GPU temperature
	FILE *power = fopen("/sys/bus/i2c/drivers/ina3221x/6-0040/iio:device0/in_power2_input","r");		// add path to the sysfs file to read GPU power
			
	size_t elements_freq = fread(gpu_freq,1,20,rate);
		
	strtok(gpu_freq,"\n");

	size_t elements_temp = fread(gpu_temp,1,20,temp);
	strtok(gpu_temp,"\n");

	size_t elements_volt = fread(gpu_voltage,1,20,voltage);
	strtok(gpu_voltage,"\n");

	size_t elements_power = fread(gpu_power,1,20,power);
	strtok(gpu_power,"\n");

	printf("\n\tInitialise PC\n");

	printf("\n\tRun benchmark\n\n");
	
	//printf("%d\n", pc);

	////initialise PC here, reset value and cycle -> gpu_counter_access.cpp
	//initcounters();
	
	clock_gettime(CLOCK_MONOTONIC,&tsample);
	starttime = (tsample.tv_sec*1.0e9 + tsample.tv_nsec)/1000000;

	system("./particlefilter/run"); //run benchmark

	clock_gettime(CLOCK_MONOTONIC,&tsample);
	timenow = (tsample.tv_sec*1.0e9+tsample.tv_nsec)/1000000;

	////record PC here, value and cycle -> gpu_counter_access.cpp
	//getcountersvalue();
	
	printf("\n\tBenchmark run complete\n");

	printf("\n\tmeasure_gpu_pow.c::gpu_read_samples: timestamp is: %f \n",timenow);

	fclose(rate);
	fclose(temp);
	fclose(voltage);
	fclose(power);
		
	float timesample = (timenow-starttime);	// Duration of BM run
	printf("\tmeasure_gpu_pow.c::gpu_read_samples: duration of BM run in ms : %f \n",timesample);
	
	int gpufreqMHz = atoi(gpu_freq)/1000;	// GPU freq in kHz
	printf("\tmeasure_gpu_pow.c::gpu_read_samples: GPU freq in kHz : %d \n",gpufreqMHz);

	float gputempdeg = atoi(gpu_temp)/1000;		// GPU temp in degrees
	printf("\tmeasure_gpu_pow.c::gpu_read_samples: GPU temp in degrees : %f \n",gputempdeg);

	float gpuvoltageV = atoi(gpu_voltage)/1000.0;	// GPU voltage in Volt
	printf("\tmeasure_gpu_pow.c::gpu_read_samples: GPU Voltage in V : %f \n",gpuvoltageV);

	float gpuvoltageW = atoi(gpu_power)/1000.0;	// GPU power in Volt
	printf("\tmeasure_gpu_pow.c::gpu_read_samples: GPU power in W : %f \n",gpuvoltageW);

	printf("\n\tRecord PC and sensor data for run\n\n");

	printf("\n\t-------------------EXITING data_retrieval_particlefilter-------------------\n\n");
}

