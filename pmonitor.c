/*******************************************************************************
--------------------------------------------------------------------------------

	File		: 	pmonitor.c

	Date		: 	15/02/2022
		
	Author		:	Matthew Burgess, building on the work of Deepthi Nanduri and Dr Jose Nunez-Janez
		
	Description	:	File controlling the method of setting GPU frequencies and recording data of GPU from benchmark run
				This script is adopted from work of Nunez-Yanez et al
				This file will be used in conjunction with the functions file measurement_threads.c
							
----------------------------------------------------------------------------------
**********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "cusparse.h"

#include "utilities.h"
#include "monitoring.h"
#include "jnano_inst.h"
#include "unistd.h"

extern char log_file_name[1000];

int pc;


int main(void) {


	FILE* fp_v;

	strcpy(log_file_name, "log_power_monitor");
	file_power_profile_create(log_file_name);
	fp_v=fopen(log_file_name, "a");

	char cmdbuf[256];

	int freqs_gpu[12] = {76800000, 153600000, 230400000, 307200000, 384000000, 460800000, 537600000, 614400000, 691200000, 768000000, 844800000, 921600000};    //GPU frequencies in MHz, mult 76.8

	for(pc=0;pc<1;pc++) //loop through freqs for each performance counter (13 counters)
	{
		printf("\n\tResetting GPU configuration, reset GPU frequency to %d\n\n", freqs_gpu[0]);
	
		snprintf(cmdbuf,sizeof(cmdbuf),"./jetson_clocks.sh --set %d",freqs_gpu[0]);
	
		system(cmdbuf);
	
		usleep(1000000);
	
		printf("\n\tInitialising power monitoring loop for current PC\n");
	
		power_monitoring_prologue();
		
		for(int gfreq=0;gfreq<12;gfreq++)
		{
			printf("\n\tSet GPU freq to %d for new benchmark run\n", freqs_gpu[gfreq]);
			
			snprintf(cmdbuf,sizeof(cmdbuf),"./jetson_clocks.sh --set %d",freqs_gpu[gfreq]);
	
			system(cmdbuf);
	
			//system("./particlefilter/run"); //launch benchmark -> command moved into data_retrieval_particlefilter() to resolve timing issues
			data_retrieval_particlefilter();
		}
	
		power_monitoring_epilogue();
	}
 
	printf("Finishing power monitor\n");

	printf("Read GPU freqs\n");

	system("./jetson_clocks.sh --read");

	power_monitoring_stop();

	return 0;	
}

