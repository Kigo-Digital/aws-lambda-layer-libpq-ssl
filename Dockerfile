FROM amazonlinux:2023

ARG postgresql_version
ARG zipfile="libpq_layer.zip"

# Install necessary packages
RUN yum update -y && \
  yum install -y tar bzip2 make gcc openssl-devel shadow-utils readline-devel zlib-devel --allowerasing && \
  yum install -y curl --allowerasing

# Create a non-root user to perform the build
RUN useradd -m builder

# Set the working directory
WORKDIR /home/builder

# Download and unpack PostgreSQL
RUN curl -fsSL https://ftp.postgresql.org/pub/source/v${postgresql_version}/postgresql-${postgresql_version}.tar.bz2 \
  -o postgresql-${postgresql_version}.tar.bz2 && \
  tar -xjf postgresql-${postgresql_version}.tar.bz2

# Build PostgreSQL
RUN cd postgresql-${postgresql_version} && \
  ./configure --prefix=/home/builder/local --with-openssl && \
  make install

# Create a ZIP file of the necessary libraries
RUN cd /home/builder/local && \
  zip --must-match -r /home/builder/${zipfile} lib/libpq.so*
