//File for accessing GPU performance counters

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
//#include "jnano_inst.h"
//#include "monitoring.h"

// performance counters
#define S_OK 0x00000000
#define NVPM_INITGUID
#include "NvPmApi.Manager.h"
#include "NvPmApi.h"
#include "unistd.h"
#include "iostream"

extern int pc;
FILE *fp_log;

// Simple singleton implementation for grabbing the NvPmApi
static NvPmApiManager S_NVPMManager;
extern NvPmApiManager *GetNvPmApiManager() {return &S_NVPMManager;}
const NvPmApi *GetNvPmApi() {return S_NVPMManager.Api();}
NVPMContext hNVPMContext;

//-------------------declaration of detection execution results of GetCounterValueByName()-----------------------------------------------------------

NVPMUINT64 value_0,value_1,value_2,value_3,value_4,value_5,value_6,value_7,value_8,value_9,value_10,value_11,value_12;
NVPMUINT64 cycle_0,cycle_1,cycle_2,cycle_3,cycle_4,cycle_5,cycle_6,cycle_7,cycle_8,cycle_9,cycle_10,cycle_11,cycle_12;

NVPMRESULT   inst_executed_cs_result;
NVPMRESULT   sm_inst_executed_texture_result;
NVPMRESULT   sm_executed_ipc_result;
NVPMRESULT   sm_issued_ipc_result;
NVPMRESULT   threads_launched_result;
NVPMRESULT   gpu_busy_result;
NVPMRESULT   gpu_idle_result;
NVPMRESULT   l2_write_bytes_result;
NVPMRESULT   l2_read_bytes_result;
NVPMRESULT   sm_inst_executed_global_loads_result;
NVPMRESULT   sm_inst_executed_global_stores_result;
NVPMRESULT   sm_active_cycles_result;
NVPMRESULT   sm_active_warps_result;
NVPMRESULT   sm_warps_launched_result;

double result0;
double result1;
double result2;
double result3;
double result4;
double result5;
double result6;
double result7;
double result8;
double result9;
double result10;
double result11;
double result12;

int initcounters(){

		value_0 = value_1 = value_2  = value_3 = value_4 = value_5 = value_6 = value_7 = value_8 = value_9 = value_10 = value_11 = value_12 = 0;
		cycle_0 = cycle_1 = cycle_2  = cycle_3 = cycle_4 = cycle_5 = cycle_6 = cycle_7 = cycle_8 = cycle_9 = cycle_10 = cycle_11 = cycle_12 = 0;
		//cycle through all 13 counters in order (0 through to 12), switching sequentially

		printf("...setting performance counter...\n");
		if (pc==0)
			{
			printf("counter 0 \n ");
			if(GetNvPmApiManager()->Construct(L"/home/ubuntu/Desktop/PerfKit/lib/a64/libNvPmApi.Core.so") != S_OK)
			{  std::cout <<  "Error 1" << std::endl; 
   				return false; // This is an error condition
			}
			NVPMRESULT nvResult;
			if((nvResult = GetNvPmApi()->Init()) != NVPM_OK)
			{  std::cout <<  "Error 2" << std::endl; 
   				return false; // This is an error condition
			}

			if((nvResult = GetNvPmApi()->CreateContextFromCudaContext(0, &hNVPMContext)) != NVPM_OK)
			{  std::cout <<  "Error 3" << std::endl; 
   				return false; // This is an error condition
			}

			fp_log = fopen("power_measurement_log_c0.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c0.dat file \n ");
				return 0;
				}
			GetNvPmApi()->AddCounterByName(hNVPMContext,"inst_executed_cs");
			inst_executed_cs_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"inst_executed_cs",0,&value_0,&cycle_0);
			}		
			//break;

		if (pc==1)
			{
			printf("counter 1 \n ");
			fp_log = fopen("power_measurement_log_c1.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c1.dat file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"inst_executed_cs");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_inst_executed_texture");
			sm_inst_executed_texture_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_inst_executed_texture",0,&value_1,&cycle_1);
			}
			//break;

		if (pc==2)
			{
			printf("counter 2 \n ");
			fp_log = fopen("power_measurement_log_c2.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c2.dat file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_inst_executed_texture");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_inst_executed_global_loads");
			sm_inst_executed_global_loads_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_inst_executed_global_loads",0,&value_2,&cycle_2);
			}
			//break;

		if (pc==3)
			{
			printf("counter 3 \n ");
			fp_log = fopen("power_measurement_log_c3.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c3.dat file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_inst_executed_global_loads");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_inst_executed_global_stores");
			sm_inst_executed_global_stores_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_inst_executed_global_stores",0,&value_3,&cycle_3);
			}
			//break;

		if (pc==4)
			{
			printf("counter 4 \n ");
			fp_log = fopen("power_measurement_log_c4.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c4.dat file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_inst_executed_global_stores");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"threads_launched");
			threads_launched_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"threads_launched",0,&value_4,&cycle_4);
			}
			//break;

		if (pc==5)
			{
			printf("counter 5 \n ");
			fp_log = fopen("power_measurement_log_c5.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c5.dat file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"threads_launched");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"gpu_busy");
			gpu_busy_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"gpu_busy",0,&value_5,&cycle_5);
			}
			//break;
	
		if (pc==6)
			{
			printf("counter 6 \n ");
			fp_log = fopen("power_measurement_log_c6.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c8.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"gpu_busy");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_executed_ipc");
			sm_executed_ipc_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_executed_ipc",0,&value_6,&cycle_6);
			}
			//break;

		if (pc==7)
			{
			printf("counter 7 \n ");
			fp_log = fopen("power_measurement_log_c7.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c7.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_executed_ipc");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_issued_ipc");
			sm_issued_ipc_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_issued_ipc",0,&value_7,&cycle_7);
			}
			//break;

		if (pc==8)
			{
			printf("counter 8 \n ");
			fp_log = fopen("power_measurement_log_c8.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c8.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_issued_ipc");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"l2_write_bytes");
			l2_write_bytes_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"l2_write_bytes",0,&value_8,&cycle_8);
			}
			//break;

		if (pc==9)
			{
			printf("counter 9 \n ");
			fp_log = fopen("power_measurement_log_c9.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c9.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"l2_write_bytes");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"l2_read_bytes");
			l2_read_bytes_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"l2_read_bytes",0,&value_9,&cycle_9);
			}
			//break;

		if (pc==10)
			{
			printf("counter 10 \n ");
			fp_log = fopen("power_measurement_log_c10.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c10.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"l2_read_bytes");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_active_cycles");
			sm_active_cycles_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_active_cycles",0,&value_10,&cycle_10);
			}
			//break;

		if (pc==11)
			{
			printf("counter 11 \n ");
			fp_log = fopen("power_measurement_log_c11.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c11.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_active_cycles");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_active_warps");
			sm_active_warps_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_active_warps",0,&value_11,&cycle_11);
			}
			//break;

		if (pc==12)
			{
			printf("counter 12 \n ");
			fp_log = fopen("power_measurement_log_c12.dat", "w");
			if (!fp_log) {
				printf("cannot open power_measurement_log_c12.txt file \n ");
				return 0;
				}
			GetNvPmApi()->RemoveCounterByName(hNVPMContext,"sm_active_warps");
			GetNvPmApi()->AddCounterByName(hNVPMContext,"sm_warps_launched");
			sm_warps_launched_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_warps_launched",0,&value_12,&cycle_12);
			}
			//break;
		return 0;
}

int getcountersvalue(){ 
	if (pc==0){
		inst_executed_cs_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"inst_executed_cs",0,&value_0,&cycle_0);
		result0 = 100*double(value_0)/double(cycle_0);
		}
		//break;

	if (pc==1){
		sm_inst_executed_texture_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_inst_executed_texture",0,&value_1,&cycle_1);
		result1 = 100*double(value_1)/double(cycle_1);
		}
		//break;

	if (pc==2){
		sm_inst_executed_global_loads_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_inst_executed_global_loads",0,&value_2,&cycle_2);
		result2 = 100*double(value_2)/double(cycle_2);
		}
		//break;

	if (pc==3){
		sm_inst_executed_global_stores_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_inst_executed_global_stores",0,&value_3,&cycle_3);
		result3 = 100*double(value_3)/double(cycle_3);
		}
		//break;

	if (pc==4){
		threads_launched_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"threads_launched",0,&value_4,&cycle_4);
		result4 = 100*double(value_4)/double(cycle_4);
		}
		//break;

	if (pc==5){
		gpu_busy_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"gpu_busy",0,&value_5,&cycle_5);
		result5 = 100*double(value_5)/double(cycle_5);
		}
		//break;

	if (pc==6){
		sm_executed_ipc_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_executed_ipc",0,&value_6,&cycle_6);
		result6 = 100*double(value_6)/double(cycle_6);
		}
		//break;

	if (pc==7){
		sm_issued_ipc_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_issued_ipc",0,&value_7,&cycle_7);
		result7 = 100*double(value_7)/double(cycle_7);
		}
		//break;

	if (pc==8){	
		l2_write_bytes_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"l2_write_bytes",0,&value_8,&cycle_8);
		result8 = 100*double(value_8)/double(cycle_8);
		}
		//break;

	if (pc==9){
		l2_read_bytes_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"l2_read_bytes",0,&value_9,&cycle_9);
		result9 = 100*double(value_9)/double(cycle_9);
		}
		//break;

	if (pc==10){
		sm_active_cycles_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_active_cycles",0,&value_10,&cycle_10);
		result10 = 100*double(value_10)/double(cycle_10);
		}
		//break;

	if (pc==11){
		sm_active_warps_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_active_warps",0,&value_11,&cycle_11);
		result11 = 100*double(value_11)/double(cycle_11);
		}
		//break;

	if (pc==12){
		sm_warps_launched_result = GetNvPmApi()->GetCounterValueByName(hNVPMContext,"sm_warps_launched",0,&value_12,&cycle_12);
		result12 = 100*double(value_12)/double(cycle_12);
		}
		//break;
	return 0;
}

