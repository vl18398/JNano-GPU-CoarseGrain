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

for(pc=0;pc<12;pc++) //loop through freqs for each performance counter
{
	printf("Setting GPU freqs\n");

	snprintf(cmdbuf,sizeof(cmdbuf),"./jetson_clocks.sh --set %d",freqs_gpu[0]);

	system(cmdbuf);

	usleep(1000000);

	printf("Starting power monitor\n");

	power_monitoring_prologue ();
	
	for(int gfreq=0;gfreq<12;gfreq++)
	{
		snprintf(cmdbuf,sizeof(cmdbuf),"./jetson_clocks.sh --set %d",freqs_gpu[gfreq]);

		system(cmdbuf);

		system("./particlefilter/run"); //launch benchmark
	}

	power_monitoring_epilogue();
}
 
printf("Finishing power monitor\n");

printf("Read GPU freqs\n");

system("./jetson_clocks.sh --read");


return 0;	
}







