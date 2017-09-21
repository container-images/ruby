FROM registry.fedoraproject.org/fedora:26

# This image provides a Ruby 2.4 environment you can use to run your Ruby
# applications.

EXPOSE 8080

ENV NAME=ruby \
    RUBY_VERSION=2.4 \
    VERSION=0 \
    RELEASE=1 \
    ARCH=x86_64 \
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

ENV SUMMARY="Platform for building and running Ruby $RUBY_VERSION applications" \
    DESCRIPTION="Ruby $RUBY_VERSION available as docker container is a base platform for \
building and running various Ruby $RUBY_VERSION applications and frameworks. \
Ruby is the interpreted scripting language for quick and easy object-oriented programming. \
It has many features to process text files and to do system management tasks (as in Perl). \
It is simple, straight-forward, and extensible."

LABEL summary="$SUMMARY" \
      name="$FGC/$NAME" \
      com.redhat.component="$NAME" \
      release="RELEASE.$DISTTAG" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Ruby 2.4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,ruby24,rh-ruby24" \
      io.openshift.s2i.scripts-url="$STI_SCRIPTS_URL" \
      usage="s2i build <SOURCE-REPOSITORY> php <APP-NAME>"

# Install required packages
RUN INSTALL_PKGS="bsdtar \
	findutils \
	gettext \
	tar \
	bzip2 \
	gcc-c++ \
	gd-devel \
	gdb \
	git \
	libcurl-devel \
	libxml2-devel \
	libxslt-devel \
	lsof \
	make \
	mariadb-devel \
	mariadb-libs \
	npm \
	openssl-devel \
	patch \
	postgresql-devel \
	procps-ng \
	python \
	sqlite-devel \
	unzip \
	wget \
	which \
	cmake \
	redhat-rpm-config" &&  \
	dnf install -y --setopt=tsflags=nodocs ruby ruby-devel rubygem-rake rubygem-bundler rubygems-devel nodejs $INSTALL_PKGS && \
	dnf clean all -y && \
	mkdir -p ${HOME} && \
	useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
  	chown -R 1001:0 /opt/app-root

WORKDIR ${HOME}

# S2I scripts
COPY ./s2i/bin/  $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

RUN chown -R 1001:0 /opt/app-root && chmod -R ug+rwx /opt/app-root

USER 1001

# Command which will start service during command `docker run`
CMD $STI_SCRIPTS_PATH/usage