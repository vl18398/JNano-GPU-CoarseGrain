/*
 * measurement_threads.c
 *
 *  Created on: May 15, 2015
 *      Author: csxmh
 */

#define _GNU_SOURCE             /* See feature_test_macros(7) */
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

int start;
pthread_mutex_t mutex;

int stop;
pthread_t  thread_ID;
void      *exit_status;
struct jetsonnano_sample * head;

long long int sample_count = 0;

double   gpu_power_total=0;
double   cpu_power_total=0;
double   in_power_total=0;



void *jetsonnano_read_samples(void *head) {

	FILE *fp_log;
	unsigned int gpu_power_value;
	unsigned int cpu_power_value;
	unsigned int in_power_value;


//	int i;
//	struct  jetsonnano_sample *t = (struct jetsonnano_sample*) head;
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

		



		jnano_get_ina3221(VDD_IN,  POWER,  &in_power_value);
		jnano_get_ina3221(VDD_GPU, POWER,  &gpu_power_value);
		jnano_get_ina3221(VDD_CPU, POWER,  &cpu_power_value);

		fprintf(fp_log, "gpu_power = %u \n",   gpu_power_value);

		gpu_power_total    += gpu_power_value;
		cpu_power_total    += cpu_power_value;
		in_power_total     += in_power_value;
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


	cpu_set_t cpu_set2;
	CPU_SET(1, &cpu_set2);
	pthread_create(&thread_ID, NULL, jetsonnano_read_samples, head);
	sched_setaffinity(thread_ID, sizeof(cpu_set_t), &cpu_set2);

//	pthread_join(thread_ID, &exit_status);


	return head;
}


void jetsonnano_read_sample_start( ) {

	pthread_mutex_lock(&mutex);

	//printf("mutex is locked\n");

	sample_count = 0;
	gpu_power_total    = 0;
	cpu_power_total   = 0;
	in_power_total    = 0;


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



void jetsonnano_save_average_pthread(struct jetsonnano_sample *head, char *file_name) {

	FILE *fp;


//	struct jetsonnano_sample *sample = head;

	fp=fopen(file_name, "a");



	fprintf(fp, "gpu_power_average = %f count = %llu\n",   gpu_power_total/sample_count, sample_count);

	fprintf(fp, "cpu_power_average = %f count = %llu\n",   cpu_power_total/sample_count, sample_count);

	fprintf(fp, "in_power_average = %f count = %llu\n",   in_power_total/sample_count, sample_count);
	fprintf(fp, "--------------------------------------\n");

	fclose(fp);
}

void jetsonnano_clear_sample_pthread(struct jetsonnano_sample *head) {

	struct jetsonnano_sample *sample = head;
	while (sample != (struct jetsonnano_sample *)NULL) {
		struct jetsonnano_sample *next = sample->next;
		free (sample);
		sample = next;
	}
	pthread_mutex_destroy(&mutex);
}
