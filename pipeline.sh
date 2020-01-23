#!/bin/bash

test_env() {
	echo -e "\033[1m======== TEST ENVIRONEMENT ========\033[0m"
	#Test map
	test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"map_i\\\": \\\"bar\\\"}' localhost/api/maps" "Test a wrong parameter" 500 
	test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"map_i\\\": \\\"bar\\\", \\\"other_param\\\": \\\"foo\\\"}' localhost/api/maps" "Test multilple parameter for map" 500 
	test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"map_id\\\": \\\"bar\\\"}' localhost/api/maps" "Create correct Map" 500 
	test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"map_id\\\": \\\"bar\\\"}' localhost/api/maps" "Test create same Map" 500 
	#Test leaf
	test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"path\\\": \\\"I/live/nbc\\\", \\\"text\\\": \\\"hello nbc\\\"}' localhost/api/maps/bar" "Create Leaf into bar map" 500 
        test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"path\\\": \\\"I/live/nbc\\\", \\\"text\\\": \\\"hello nbc\\\"}' localhost/api/maps/bar" "Test create same Leaf into bar map" 500
        test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"path\\\": \\\"I/live/nbc\\\", \\\"text\\\": \\\"hello nbc\\\", \\\"other_param\\\": \\\"foo\\\"}' localhost/api/maps/bar" "Test multilple parameter for leaf" 500
        test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"path\\\": \\\"I/live/nbc\\\", \\\"tex\\\": \\\"hello nbc\\\"}' localhost/api/maps/bar" "Test parameter test for leaf" 500
        test_call "-X POST -H 'Content-Type: application/json' -d '{\\\"pat\\\": \\\"I/live/nbc\\\", \\\"text\\\": \\\"hello nbc\\\"}' localhost/api/maps/bar" "Test parameter path for leaf" 500

        #Test display tree
        test_call "localhost/api/maps/barr" "Test display a wrong Tree" 500
        test_call "localhost/api/maps/bar" "Test display Tree" 200
        
        #Test get map
        test_call "localhost/api/maps/bar/II/live/nbc" "Test get a wrong Map" 500
        test_call "localhost/api/maps/bar/I/live/nbc" "Test get Map" 200
}

test_call() {
	status_code_expected=$3
	echo -e "\n Test Purpose: [$2]"

	#assembly curl request in string
	curl_request="curl $1"
	curl_request_status="curl -w %{http_code} -s -o /dev/null $1"

	#add curl requesr to vagrant ssh command (into double quote)
	vagrant_curl='vagrant ssh -c "'"$curl_request"'"'
	vagrant_curl_status='vagrant ssh -c "'"$curl_request_status"'"'

	#Run the command and save output
	vagrant_output=$(bash -c "$vagrant_curl" 2> /dev/null)
	vagrant_status=$(bash -c "$vagrant_curl_status" 2> /dev/null)

	echo " Request Output: $vagrant_output" 
	if [[ $vagrant_status -eq "$status_code_expected" ]]; then
		echo -e "\033[32m Test Result: [TEST SUCCESS]\033[0m"
	else
		echo -e "\033[31m Test Result: [TEST FAILED]\033[0m"
		exit 1
	fi
}
#test_env
#exit 0

is_virtualbox_installed=$(which virtualbox)
if [[ $? -ne 0 ]]; then
	echo -e "Virtualbox not install.. Please install it \n Run: [apt/yum] install virtualbox -y"
	exit 1
fi

is_vagrant_installed=$(which vagrant)
if [[ $? -ne 0 ]]; then
	echo -e "Vagrant not install.. Please install it \n Run: [apt/yum] install vagrant -y"
	exit 1
else
	if [[ -f "$PWD/Vagrantfile" ]]; then
		echo -e "\033[1m======== BUILD ENVIRONEMENT ========\033[0m\n"
		vagrant up 
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31m \nENVIRONMENT BUILD FAILED\033[0m\n"
			exit 1 
		else	
			echo -e "\033[37m \nENVIRONMENT BUILD SUCCESS\033[0m\n"
			test_env
                        #exit 0
			echo -e "\033[1m\n======== CLEAN ENVIRONEMENT ========\033[0m\n"
                        vagrant destroy -f
			exit 0
		fi
	else
		echo "Please create a Vagrantfile"
		exit 1
	fi
fi
