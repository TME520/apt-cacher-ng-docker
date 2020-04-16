#
# Build: docker build -t apt-cacher .
# Run: docker run -d -p 3142:3142 --name apt-cacher-run apt-cacher
#
# and then you can run containers with:
#   docker run -t -i --rm -e http_proxy http://dockerhost:3142/ debian bash
#
# Here, `dockerhost` is the IP address or FQDN of a host running the Docker daemon
# which acts as an APT proxy server.
FROM        ubuntu
LABEL Name="apt-cacher-ng" Version="1.0" Maintainer="TME520" Environment="DEV"

ENV APT_CACHER_NG_VERSION=3.1 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=root

RUN apt update && \
    apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y apt-cacher-ng=${APT_CACHER_NG_VERSION}* ca-certificates wget openssh-server supervisor sudo curl vim lsof && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Folder needed by OpenSSH
RUN mkdir -p /var/run/sshd

# Copy configuration files
COPY ./config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./config/openssh/ /etc/ssh/
COPY ./entrypoint.sh /

# root passwd change + user for SSH
RUN echo "root:Docker!" | chpasswd
RUN useradd -d /home/human -m -s /bin/bash human && echo "human:NEWPASSWORDHERE" | chpasswd && adduser human sudo
RUN mkdir -p /home/human/.ssh/ && \
    chmod 0700 /home/human/.ssh/
COPY ./config/openssh/id_rsa_onepoint_human.pub /home/human/.ssh/
RUN chmod 0600 /home/human/.ssh/id_rsa_human.pub
RUN touch /home/human/.ssh/authorized_keys
RUN chmod 0600 /home/human/.ssh/authorized_keys
RUN cat /home/human/.ssh/id_rsa_human.pub >> /home/human/.ssh/authorized_keys
RUN chown -R human:human /home/human/

EXPOSE      2222/tcp 3142/tcp

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
    CMD wget -q0 - http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT [ "/bin/bash", "entrypoint.sh" ]
