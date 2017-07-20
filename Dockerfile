FROM armhf/alpine
LABEL architecture="ARMv7"

# Resin's qemu for cross-compiling support
ADD qemu-arm-static.tar.gz /
ADD megaupload_credentials.txt /tmp/

RUN apk add --no-cache curl-dev git make automake autoconf wget gcc g++ \
	libssl1.0 libcurl glib-dev gobject-introspection asciidoc tar sed && \

	wget https://ftp.gnu.org/gnu/gcc/gcc-4.9.2/gcc-4.9.2.tar.gz

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
	cd /opt/ && rm -rf /tmp/*

RUN apk add linux-headers
RUN cd /opt/*LinuxEmbedded*/sdk/nscapi/sample/nscapidemo && \
	gcc -v

WORKDIR /opt
ENTRYPOINT /bin/sh

