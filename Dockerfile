# Use Amazon Linux 2023 as the base image for compatibility with provided.al2023 runtime
FROM amazonlinux:2023

# Define build argument for the output zip file name
ARG zipfile="libpq_layer.zip"

# Install required packages:
# postgresql-libs for libpq
# openldap-compat for libldap_r-2.4.so.2
# cyrus-sasl-lib for libsasl2.so.3 (dependency of libldap)
# zip for packaging
RUN yum update -y && \
  yum install -y postgresql-libs openldap-compat cyrus-sasl-lib zip --allowerasing

# Create a temporary staging directory for the layer contents
RUN mkdir -p /lambda_layer_content/lib

# Copy shared libraries into the 'lib' subdirectory of our staging area
RUN cp /usr/lib64/libpq.so* /lambda_layer_content/lib/ && \
  cp /usr/lib64/libldap_r-2.4.so.2* /lambda_layer_content/lib/ && \
  cp /usr/lib64/liblber-2.4.so.2* /lambda_layer_content/lib/ && \
  cp /usr/lib64/libsasl2.so.3* /lambda_layer_content/lib/ && \
  # Set executable permissions to ensure accessibility in Lambda runtime
  chmod 755 /lambda_layer_content/lib/*

# Package the files into a zip.
# Change directory to the staging area so that 'lib' is at the root of the zip.
WORKDIR /lambda_layer_content
RUN zip -r /${zipfile} lib

# (Optional) You might want to WORKDIR back to / or another directory if you have more commands
# WORKDIR /
