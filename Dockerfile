FROM jupyter/base-notebook:6c85e4b43a26 AS build

USER root

# Ensure ECMWF's HTTP proxy does not get in the way (thanks to bentorey.hernandez@ecmwf.int).
RUN set -ex \
	&& echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo 'Acquire::http::No-Cache=True;' >> /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo 'Acquire::BrokenProxy=true;' >> /etc/apt/apt.conf.d/99fixbadproxy

# Install build-time dependencies.
RUN set -ex \
	&& apt-get update \
	&& apt-get install --yes --no-install-suggests --no-install-recommends \
	bison \
	cmake \
	file \
	flex \
	g++ \
	gcc \
	gfortran \
	git \
	libarmadillo-dev \
	libatlas-base-dev \
	libboost-dev \
	libbz2-dev \
	libc6-dev \
	libcairo2-dev \
	libcurl4-openssl-dev \
	libeigen3-dev \
	libexpat1-dev \
	libffi-dev \
	libfftw3-dev \
	libfreetype6-dev \
	libfribidi-dev \
	libgdal-dev \
	libgdbm-dev \
	libgeos-dev \
	libharfbuzz-dev \
	libhdf5-dev \
	libjpeg-dev \
	liblapack-dev \
	liblzma-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libnetcdf-cxx-legacy-dev \
	libnetcdf-dev \
	libpango1.0-dev \
	libpcre3-dev \
	libpng-dev \
	libproj-dev \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	libxml-parser-perl \
	libxml2-dev \
	libxslt1-dev \
	libyaml-dev \
	make \
	patch \
	swig \
	uuid-dev \
	zlib1g-dev

# Install Python modules.
RUN set -ex \
	&& pip install \
	cdsapi==0.1.1 \
	cfgrib==0.9.2 \
	ecmwf-api-client==1.4.2 \
	ipyleaflet==0.9.1 \
	ipywidgets==7.4.2 \
	jupyterhub==0.9.4 \
	jupyterlab==0.35.2 \
	notebook==5.7.0 \
	numpy==1.15.2 \
	pandas==0.23.4 \
	xarray==0.10.9 \
	&& fix-permissions $CONDA_DIR \
	&& fix-permissions /home/$NB_USER

# Install ecbuild.
ENV ECBUILD_VERSION=2.9.1

RUN set -eux \
	&& mkdir -p /src \
	&& cd /src \
	&& wget -O - https://github.com/ecmwf/ecbuild/archive/${ECBUILD_VERSION}.tar.gz | tar xvzf - \
	&& mkdir -p /build/ecbuild \
	&& cd /build/ecbuild \
	&& cmake /src/ecbuild-${ECBUILD_VERSION} -DCMAKE_BUILD_TYPE=Release \
	&& make -j$(nproc) \
	&& make install

COPY .netrc $HOME/

# Install Magics++.
ENV MAGICS_BUNDLE_VERSION=3.3.0.1

RUN set -eux \
	&& mkdir -p /src \
	&& cd /src \
	&& git clone https://git.ecmwf.int/scm/mag/magics-bundle.git \
	&& cd magics-bundle \
	&& git checkout ${MAGICS_BUNDLE_VERSION} \
	&& mkdir -p /build/magics-bundle \
	&& cd /build/magics-bundle \
	&& /usr/local/bin/ecbuild /src/magics-bundle -DECMWF_GIT=https -DCMAKE_BUILD_TYPE=Release -DENABLE_METVIEW_NO_QT=ON \
	&& make -j$(nproc) \
	&& make install

# Install libemos (for Metview).
ENV LIBEMOS_VERSION=4.5.7
RUN set -eux \
	&& mkdir -p /src \
	&& cd /src \
	&& wget -O - -q https://confluence.ecmwf.int/download/attachments/3473472/libemos-${LIBEMOS_VERSION}-Source.tar.gz?api=v2 | tar xvzf - \
	&& mkdir -p /build/libemos \
	&& cd /build/libemos \
	&& /usr/local/bin/ecbuild /src/libemos-${LIBEMOS_VERSION}-Source \
	&& make -j$(nproc) \
	&& make install

# Install Metview.
ENV METVIEW_VERSION=5.2.1
RUN set -eux \
	&& mkdir -p /src \
	&& cd /src \
	&& wget -q -O - https://confluence.ecmwf.int/download/attachments/3964985/Metview-${METVIEW_VERSION}-Source.tar.gz?api=v2 | tar xvzf - \
	&& mkdir -p /build/metview \
	&& cd /build/metview \
	&& /usr/local/bin/ecbuild /src/Metview-${METVIEW_VERSION}-Source -DENABLE_UI=OFF \
	&& make -j$(nproc) \
	&& make install

# Install Metview Python bindings.
RUN set -ex \
	&& pip install \
	metview==0.8.4 \
	&& fix-permissions $CONDA_DIR \
	&& fix-permissions /home/$NB_USER

#
# Run-time image.
#

FROM jupyter/base-notebook:6c85e4b43a26

USER root

# Ensure ECMWF's HTTP proxy does not get in the way (thanks to bentorey.hernandez@ecmwf.int).
RUN set -ex \
	&& echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo 'Acquire::http::No-Cache=True;' >> /etc/apt/apt.conf.d/99fixbadproxy \
	&& echo 'Acquire::BrokenProxy=true;' >> /etc/apt/apt.conf.d/99fixbadproxy

# Install run-time dependencies.
RUN set -ex \
	&& apt-get update \
	&& apt-get install --yes --no-install-suggests --no-install-recommends \
	ghostscript \
	imagemagick \
	ksh \
	libarmadillo8 \
	libbz2-1.0 \
	libcairo-gobject2 \
	libcairo-script-interpreter2 \
	libcairo2 \
	libcroco3 \
	libcurl4 \
	libexif12 \
	libexpat1 \
	libfftw3-double3 \
	libfftw3-long3 \
	libfftw3-quad3 \
	libfftw3-single3 \
	libfontconfig1 \
	libfreetype6 \
	libfribidi0 \
	libgdal20 \
	libgeoip1 \
	libgeos-c1v5 \
	libgif7 \
	libgomp1 \
	libgssrpc4 \
	libharfbuzz0b \
	libhdf5-100 \
	libicu60 \
	libilmbase12 \
	libjbig0 \
	libjpeg-turbo8 \
	libjpeg8 \
	libjs-jquery \
	liblcms2-2 \
	liblqr-1-0 \
	libnetcdf-c++4 \
	libnetcdf13 \
	libopenexr22 \
	libpangocairo-1.0-0 \
	libpangoxft-1.0-0 \
	libpcrecpp0v5 \
	libpng16-16 \
	libproj12 \
	libreadline7 \
	libsqlite3-0 \
	libtiff5 \
	libtiffxx5 \
	libwebp6 \
	libxft2 \
	libxml2 \
	libxslt1.1 \
	poppler-utils \
	rsync

# Copy build artifacts.
COPY --from=build /opt/conda/lib/python3.6/site-packages/ /opt/conda/lib/python3.6/site-packages/
COPY --from=build /usr/local/share/eccodes/ /usr/local/share/eccodes/
COPY --from=build /usr/local/share/libemos/ /usr/local/share/libemos/
COPY --from=build /usr/local/share/magics/ /usr/local/share/magics/
COPY --from=build /usr/local/share/metview/ /usr/local/share/metview/
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/

# Ensure shared libs installed by the previous step are available.
RUN set -ex \
	&& /sbin/ldconfig

# Switch back to jovyan to avoid accidental container runs as root.
USER $NB_UID

# Configure Python runtime.
ENV \
	PYTHONDONTWRITEBYTECODE=1 \
	PYTHONPATH=/usr/local/lib/python3.6/site-packages \
	PYTHONUNBUFFERED=1
