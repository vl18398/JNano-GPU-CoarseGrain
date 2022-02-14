#include "monitoring.h"

struct jetsonnano_sample *head;

char log_file_name[1000];
void file_power_profile_create (char *file_name) {
	strcat(file_name, ".txt");

	FILE *fp=fopen(file_name, "a");
	fclose(fp);
}

void power_monitoring_prologue () {
	head = (struct jetsonnano_sample *)jetsonnano_read_sample_pthread();
	jetsonnano_read_sample_start();
}

void power_monitoring_stop() {
	jetsonnano_read_sample_stop();
}

void power_monitoring_epilogue() {
	power_monitoring_stop();
	jetsonnano_clear_sample_pthread(head);
}

