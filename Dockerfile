FROM ubuntu
MAINTAINER hongbo.mo@upai.com

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/' /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list 

RUN apt-get update \
    && apt-get install -y supervisor git-core openssh-client ruby2.1 \
        zlib1g libyaml-0-2 libssl1.0.0 \
        libgdbm3 libreadline6 libncurses5 libffi6 \
        libxml2 libxslt1.1 libcurl3 libicu52 openssh-server \
    && gem install --no-document bundler \
    && rm -rf /var/lib/apt/lists/* # 20150323

# ccache
RUN apt-get update && apt-get -y install build-essential

RUN wget -O /tmp/ccache-3.2.1.tar.gz http://samba.org/ftp/ccache/ccache-3.2.1.tar.gz \
    && tar xvf /tmp/ccache-3.2.1.tar.gz -C /tmp \
    && cd /tmp/ccache-3.2.1 && ./configure && make && make install \
    && cp ccache /usr/local/bin/ \
    && ln -s ccache /usr/local/bin/gcc \
    && ln -s ccache /usr/local/bin/g++ \
    && ln -s ccache /usr/local/bin/cc \
    && ln -s ccache /usr/local/bin/c++

ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

ADD assets/init /app/init
RUN chmod 755 /app/init

# sshd config
RUN mkdir /var/run/sshd
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN echo "UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config

VOLUME ["/home/gitlab_ci_runner/data"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
