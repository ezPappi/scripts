#!/bin/sh

for (( a=1; a<255; a++)); do
	ping -c 1 192.168.99.$a
done
