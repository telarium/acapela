FROM armhf/alpine
LABEL architecture="ARMv7"

# Resin's qemu for cross-compiling support
ADD qemu-arm-static.tar.gz /
ADD megaupload_credentials.txt /tmp/

RUN apk add --no-cache git curl-dev git make automake autoconf wget gcc g++ \
	libssl1.0 libcurl glib-dev gobject-introspection \
	linux-headers asciidoc tar sed && \

	# Get MegaUpload tools to download demo
	git clone https://github.com/megous/megatools.git /tmp/megatools && \
	cd /tmp/megatools && \
	aclocal && autoheader && automake --add-missing && \
	autoreconf && ./configure && \
	make && make install && \

	# Download file from MegaUpload
	username=$(sed '1!d' /tmp/megaupload_credentials.txt ) && \
	passwd=$(sed '2!d' /tmp/megaupload_credentials.txt ) && \
	megaget '/Root/acapelaTTS.tar.gz' -u $username -p $passwd && \

	mkdir /opt && tar -zxvf acapelaTTS.tar.gz -C /opt/ && \
        cd /opt/ && rm -rf /tmp/* && \

	apk del gcc g++ && \
	echo 'http://dl-cdn.alpinelinux.org/alpine/v3.2/main' > /etc/apk/repositories && \
        apk --no-cache add gcc g++

RUN 	cp -r /opt/*LinuxEmbedded*/libraries/arm-gcc-4.9.2-gnueabihf/* /opt/*LinuxEmbedded*/libraries && \
	cd /opt/*LinuxEmbedded*/sdk/nscapi/sample/nscapidemo
	#make

WORKDIR /opt
ENTRYPOINT /bin/sh

