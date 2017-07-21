FROM armhf/debian
LABEL architecture="ARMv7"

# Resin's qemu for cross-compiling support
ADD qemu-arm-static.tar.gz /
ADD megaupload_credentials.txt /tmp/

RUN apt-get update && \
	apt-get -y install wget tar build-essential libglib2.0-dev libssl-dev \
		libcurl4-openssl-dev libgirepository1.0-dev glib-networking && \

	cd /tmp && wget http://megatools.megous.com/builds/megatools-1.9.94.tar.gz && \
	tar -xvf megatools-1.9.94.tar.gz && cd megatools-1.9.94 && \
	./configure --disable-shared && make && make install && \

	username=$(sed '1!d' /tmp/megaupload_credentials.txt ) && \
	passwd=$(sed '2!d' /tmp/megaupload_credentials.txt ) && \
	megaget '/Root/acapelaTTS.tar.gz' -u $username -p $passwd && \
	tar -zxvf acapelaTTS.tar.gz -C /opt/ && \
        cd /opt/ && rm -rf /tmp/*  && \

	cp -r /opt/*LinuxEmbedded*/libraries/arm-gcc-4.9.2-gnueabihf/* /opt/*LinuxEmbedded*/libraries && \
	cd /opt/*LinuxEmbedded*/sdk/nscapi/sample/nscapidemo && \
	make && \
	export LD_LIBRARY_PATH=/opt/*LinuxEmbedded*/libraries && \

	#apt-get -y remove --purge wget tar build-essential
	echo "done!"

WORKDIR /opt
ENTRYPOINT /bin/sh

#./nscapidemo /path/to/voices/folder

