#!/bin/bash
# Copyright (c) 2015-2016, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

CONF_FILE=${HOME}/l4t_dfs.conf
RED='\e[0;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
BRED='\e[1;31m'
BGREEN='\e[1;32m'
BBLUE='\e[1;34m'
NC='\e[0m' # No Color

do_temp()
{
	GPU_TEMP=`cat /sys/devices/virtual/thermal/thermal_zone2/temp`
	echo -e "\tGPU current temp=$GPU_TEMP"
}

read_gpu()
{
	GPU_MIN_FREQ=`cat /sys/devices/gpu.0/devfreq/57000000.gpu/min_freq`
	GPU_MAX_FREQ=`cat /sys/devices/gpu.0/devfreq/57000000.gpu/max_freq`
	GPU_CUR_FREQ=`cat /sys/kernel/debug/clk/override.gbus/clk_rate`
	GPU_CUR_VOLT=`cat /sys/bus/i2c/drivers/ina3221x/6-0040/iio:device0/in_voltage1_input`
	GPU_FREQ_OVERRIDE=`cat /sys/kernel/debug/clk/override.gbus/clk_state`

	echo "CurrentFreq=$GPU_CUR_FREQ CurrentVDD = $GPU_CUR_VOLT FreqOverride=$GPU_FREQ_OVERRIDE"
	
}

do_gpu()
{
	GPU_NEW_FREQ=$1
	echo -e "\t${GREEN}jetson_clocks.sh::do_gpu() : New Frequency to be set: $GPU_NEW_FREQ kHz"${NC}	
	
	echo 1 > /sys/kernel/debug/clk/override.gbus/clk_state
	echo $GPU_NEW_FREQ > /sys/kernel/debug/clk/override.gbus/clk_update_rate

	GPU_MIN_FREQ=`cat /sys/devices/gpu.0/devfreq/57000000.gpu/min_freq`
	GPU_MAX_FREQ=`cat /sys/devices/gpu.0/devfreq/57000000.gpu/max_freq`
	GPU_CUR_FREQ=`cat /sys/devices/gpu.0/devfreq/57000000.gpu/cur_freq`
	GPU_CUR_VOLT=`cat /sys/bus/i2c/drivers/ina3221x/6-0040/iio:device0/in_voltage1_input`
	GPU_FREQ_OVERRIDE=`cat /sys/kernel/debug/clk/override.gbus/clk_state`
	
	ret=$?
	if [ ${ret} -ne 0 ]; then
		echo "Error: Failed to set new GPU frequency!"
	fi

	#echo "CurrentFreq=$GPU_CUR_FREQ CurrentVDD = $GPU_CUR_VOLT FreqOverride=$GPU_FREQ_OVERRIDE"
}

main ()
{
	
	[ `whoami` != root ] && echo Error: Run this script\($0\) as a root user && exit 1

	GPUFREQ=$2
	export GPUFREQ

	while [ -n "$1" ]; do
		case "$1" in
			--set)
				ACTION=set
				;;
			--read)		
				ACTION=read
				;;
		esac
		shift 1
	done
	case $ACTION in
		set)
			do_gpu $GPUFREQ
			do_temp
			;;
		read)
			read_gpu
			do_temp
			;;
	esac
}

main $@
exit 0
