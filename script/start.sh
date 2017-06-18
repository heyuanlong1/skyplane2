#!/bin/bash


bin_path=./

function startclustermanager() {
	${bin_path}skynet ${bin_path}config/clustermanager_config
}
function startlogin() {
	${bin_path}skynet ${bin_path}config/login_config
}
function startlobby1() {
	${bin_path}skynet ${bin_path}config/lobby1_config
}
function starttrans1() {
	${bin_path}skynet ${bin_path}config/trans1_config
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