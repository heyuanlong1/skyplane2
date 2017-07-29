#!/bin/bash

pid_path=/var/log/skynet/pid/
bin_path=./

function stopclustermanager() {
	pid_file=${pid_path}clustermanager.pid
	if [ -f $pid_file ]; then
		kill $(cat $pid_file )
	fi
}
function stoplogin() {
	pid_file=${pid_path}login.pid
	if [ -f $pid_file ]; then
		kill $(cat $pid_file )
	fi
}
function stoplobby1() {
	pid_file=${pid_path}lobby1.pid
	if [ -f $pid_file ]; then
		kill $(cat $pid_file )
	fi
}
function stoptrans1() {
	pid_file=${pid_path}trans1.pid
	if [ -f $pid_file ]; then
		kill $(cat $pid_file )
	fi
}

case $1 in
	all )
		stopclustermanager
		stoplogin
		stoplobby1
		stoptrans1
		;;
	clustermanager )
		stopclustermanager
		;;
	login )
		stoplogin
		;;
	lobby1 )
		stoplobby1
		;;
	trans1 )
		stoptrans1
		;;
	* )
		echo "invalid arg"
		;;
esac

ps aux | grep skynet
