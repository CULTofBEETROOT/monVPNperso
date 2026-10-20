#!/bin/bash
for ii in {1..10}; do 

age -d \
	-i "/root/.ssh/thislaptop-pq-key.txt" \
	-o /home/$USER/Downloads/WGclients/client$ii.conf \
	/home/$USER/Downloads/WGclients/client$ii.conf.age;

age -d \
        -i "/root/.ssh/thislaptop-pq-key.txt" \
        -o /home/$USER/Downloads/WGclients/client$ii.png \
	/home/$USER/Downloads/WGclients/client$ii.png.age;

#qrencode -r client.conf -o client-qr.png

done
chmod -R 744 /home/$USER/Downloads/WGclients/*
