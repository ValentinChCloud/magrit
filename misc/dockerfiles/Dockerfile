FROM ubuntu:latest
MAINTAINER mth

# These environment variables are passed from Galaxy to the container
# and help you enable connectivity to Galaxy from within the container.
# This means your user can import/export data from/to Galaxy.
ENV DEBIAN_FRONTEND=noninteractive \
    API_KEY=none \
    DEBUG=false \
    PROXY_PREFIX=none \
    GALAXY_URL=none \
    GALAXY_WEB_PORT=10000 \
    HISTORY_ID=none \
    REMOTE_HOST=none



RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:fkrull/deadsnakes \
		&& apt-get update \
		&& apt-get install -y gcc libpython3.6-dev libopenblas-dev libopenblas-base \
        python3.6 python3.6-dev libgeos-dev \
        libfreetype6-dev libfreetype6 libproj-dev libspatialindex-dev libv8-3.14-dev libffi-dev \
        nodejs nodejs-dev node-gyp npm redis-server libuv1-dev unzip wget \
        libxslt1-dev libxml2 libxml2-dev libkml-dev \
    && npm -g install topojson \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/nodejs /usr/bin/node

WORKDIR /home

ENV GDALINST /home/gdalinstall
ENV GDALBUILD /home/gdalbuild
ENV GDALOPTS="  --with-geos \
		        --with-expat \
		        --without-libtool \
		        --without-gif \
		        --without-pg \
		        --without-grass \
		        --without-libgrass \
		        --without-cfitsio \
		        --without-pcraster \
		        --without-netcdf \
		        --without-gif \
		        --without-ogdi \
		        --without-fme \
		        --without-hdf4 \
		        --with-spatialite \
		        --with-static-proj4=/usr/lib"

RUN mkdir $GDALBUILD && mkdir $GDALINST && cd $GDALBUILD && wget http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz \
    && tar -xzf gdal-2.1.3.tar.gz && cd gdal-2.1.3 && ./configure --prefix=$GDALINST/gdal-2.1.3 $GDALOPTS \
	&& make -s -j 2 && make install

ENV PATH="${GDALINST}/gdal-2.1.3/bin:${PATH}"
ENV LD_LIBRARY_PATH="${GDALINST}/gdal-2.1.3/lib:${LD_LIBRARY_PATH}"

ARG CACHEBUST=1



RUN rm -rf $GDALBUILD && mkdir /home/app && cd /home/app && wget https://github.com/mthh/magrit/archive/for_galaxy.zip && unzip for_galaxy.zip && mv magrit-for_galaxy magrit



RUN wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py

RUN cd /home/app/magrit/ \
    && pip3.6 install -U -r requirements-dev.txt \
    && python3.6 setup.py build_ext --inplace




#Galaxy stuff
RUN apt-get -qq update && \
    apt-get install --no-install-recommends -y \
    wget procps nginx python python-pip net-tools nginx

# Our very important scripts. Make sure you've run `chmod +x startup.sh
# monitor_traffic.sh` outside of the container!
ADD ./startup.sh /startup.sh
ADD ./monitor_traffic.sh /monitor_traffic.sh

# Nginx configuration
RUN mkdir /import
COPY ./proxy.conf /proxy.conf

VOLUME ["/import"]
WORKDIR /import/


#Changed 9999->80, because reverse proxy will do the job
EXPOSE 80
CMD /startup.sh

