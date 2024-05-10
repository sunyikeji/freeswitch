#!/bin/bash

TOKEN=$1
RELEASE=$2

# Source the os-release file (assuming it exists)
. /etc/os-release
echo $ID
echo $VERSION_CODENAME

if [ "${ID,,}" = "debian" ]; then
	ARCH=$(dpkg --print-architecture)
	if [[ "${TOKEN}" == pat_* ]]; then
		echo "Public FreeSWITCH"

		RPI=""

		if [ "${RELEASE,,}" = "unstable" ]; then
			RELEASE="unstable"
		else
			RELEASE="release"
		fi

		if [ "${ARCH,,}" = "armhf" ]; then
			RPI="rpi/"
		fi

		rm -f /etc/apt/sources.list.d/freeswitch.list
		apt-get update && apt-get install -y gnupg2 wget software-properties-common apt-transport-https

		wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/${RPI}debian-release/signalwire-freeswitch-repo.gpg
		echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf
		chmod 600 /etc/apt/auth.conf
		echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/${RPI}debian-${RELEASE}/ ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/freeswitch.list
		echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/${RPI}debian-${RELEASE}/ ${VERSION_CODENAME} main" >> /etc/apt/sources.list.d/freeswitch.list

		apt-get update
		echo "To install FreeSWITCH type: apt-get install -y freeswitch-meta-all"
	elif [[ "${TOKEN}" == fse_* ]]; then
		echo "FreeSWITCH Enterprise"

		if [ "${RELEASE,,}" = "unstable" ]; then
			RELEASE="unstable"
		else
			RELEASE="1.8"
		fi

		if [ "${ARCH,,}" = "armhf" ]; then
			RPI="-rpi"
		fi

		rm -f /etc/apt/sources.list.d/freeswitch.list
		apt-get update && apt-get install -y gnupg2 wget software-properties-common apt-transport-https

		wget --http-user=signalwire --http-password=$TOKEN -O - https://fsa.freeswitch.com/repo/deb/fsa${RPI}/pubkey.gpg | apt-key add -
		echo "machine fsa.freeswitch.com login $USERNAME password $PASSWORD" > /etc/apt/auth.conf
		chmod 600 /etc/apt/auth.conf
		echo "deb https://fsa.freeswitch.com/repo/deb/fsa${RPI}/ ${VERSION_CODENAME} ${RELEASE}" > /etc/apt/sources.list.d/freeswitch.list
		echo "deb-src https://fsa.freeswitch.com/repo/deb/fsa${RPI}/ ${VERSION_CODENAME} ${RELEASE}" >> /etc/apt/sources.list.d/freeswitch.list

		apt-get update
		echo "To install FreeSWITCH type: apt-get install -y freeswitch-meta-all"
	else
		echo "Unrecognized token type"
	fi
fi