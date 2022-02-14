#ifndef __MONITORING__H__
#define __MONITORING__H__

#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>

int start;
pthread_mutex_t mutex;

int stop;
pthread_t  thread_ID;
void      *exit_status;
struct jetsonnano_sample * head;


struct jetsonnano_sample {

	struct timeval start_time;
	struct timeval end_time;


	double  gpu_power;
	double  cpu_power;
	double  in_power;


	struct jetsonnano_sample *next;
};


void *jetsonnano_read_samples(void *head);
void *jetsonnano_read_sample_pthread();
void jetsonnano_read_sample_start();
void jetsonnano_read_sample_stop(); 
void jetsonnano_save_average_pthread(struct jetsonnano_sample *head, char *file_name);
void jetsonnano_clear_sample_pthread(struct jetsonnano_sample *head);


void file_power_profile_create (char *file_name);
void power_monitoring_prologue();
void power_monitoring_epilogue();
void power_monitoring_stop();



#endif //__MONITORING__H__
