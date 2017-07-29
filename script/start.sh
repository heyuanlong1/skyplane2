#!/bin/bash

pid_path=/var/log/skynet/pid/
bin_path=./

function startclustermanager() {
	pid_file=${pid_path}clustermanager.pid
	count=0
	if [ -f $pid_file ]; then
		count=$(ps aux | grep $(cat $pid_file) | grep -v grep | wc -l)
		if [ $count -eq 0 ]; then
			${bin_path}skynet ${bin_path}config/clustermanager_config
		fi
	else
		${bin_path}skynet ${bin_path}config/clustermanager_config
	fi
}
function startlogin() {
	pid_file=${pid_path}login.pid
	count=0
	if [ -f $pid_file ]; then
		count=$(ps aux | grep $(cat $pid_file) | grep -v grep | wc -l)
		if [ $count -eq 0 ]; then
			${bin_path}skynet ${bin_path}config/login_config
		fi
	else
		${bin_path}skynet ${bin_path}config/login_config
	fi
}
function startlobby1() {
	pid_file=${pid_path}lobby1.pid
	count=0
	if [ -f $pid_file ]; then
		count=$(ps aux | grep $(cat $pid_file) | grep -v grep | wc -l)
		if [ $count -eq 0 ]; then
			${bin_path}skynet ${bin_path}config/lobby1_config
		fi
	else
		${bin_path}skynet ${bin_path}config/lobby1_config
	fi
}
function starttrans1() {
	pid_file=${pid_path}trans1.pid
	count=0
	if [ -f $pid_file ]; then
		count=$(ps aux | grep $(cat $pid_file) | grep -v grep | wc -l)
		if [ $count -eq 0 ]; then
			${bin_path}skynet ${bin_path}config/trans1_config
		fi
	else
		${bin_path}skynet ${bin_path}config/trans1_config
	fi
}

case $1 in
	all )
		startclustermanager
		startlogin
		startlobby1
		starttrans1
		;;
	clustermanager )
		startclustermanager
		;;
	login )
		startlogin
		;;
	lobby1 )
		startlobby1
		;;
	trans1 )
		starttrans1
		;;
	* )
		echo "invalid arg"
		;;
esac

ps aux | grep skynet
