ARG ALPINE_VERSION=latest
FROM docker.io/gautada/alpine:$ALPINE_VERSION as build

# ╭――――――――――――――――――――╮
# │ VERSIONS           │
# ╰――――――――――――――――――――╯
ARG IMAGE_VERSION="2.12.17"

RUN /sbin/apk add --no-cache ansible go go-task npm openssh-client-default
WORKDIR /opt
RUN git config --global advice.detachedHead false \
 && git clone --branch "v${IMAGE_VERSION}" --depth 1 https://github.com/ansible-semaphore/semaphore.git
WORKDIR /opt/semaphore
RUN git config --global --add safe.directory /opt/semaphore \
 && /usr/bin/go-task deps \
 && /usr/bin/go-task build

FROM docker.io/gautada/alpine:$ALPINE_VERSION as container

# ╭――――――――――――――――――――╮
# │ USERS              │
# ╰――――――――――――――――――――╯
ARG USER=semaphore
# Set shell to /bin/ash and enable pipefail for Alpine-based images
# SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN /usr/sbin/usermod -l $USER alpine \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER alpine \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
# COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# COPY backup /etc/container/backup

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="semaphore"
LABEL org.opencontainers.image.description="A semaphore/ansible container."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/semaphore"
LABEL org.opencontainers.image.source="https://github.com/gautada/semaphore"
LABEL org.opencontainers.image.version="${CONTAINER_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭―
# │ APPLICATION
# ╰――――――――――――――――――――
# RUN chown -R $USER:$USER /opt/semaphore
# curl -sL https://taskfile.dev/install.sh | sh
# ./bin/task -t Taskfile.yml deps
COPY --from=build /opt/semaphore/bin/semaphore /opt/semaphore/semaphore
RUN /bin/ln -fsv /opt/semaphore/semaphore /usr/bin/semaphore \
 && /bin/ln -fsv /mnt/volumes/configmaps/config.json /home/$USER/config.json \
 && mkdir -p /home/$USER/data 
# /bin/ln -fsv /mnt/volumes/container /home/$USER/data

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER
# USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
VOLUME /mnt/volumes/logs
VOLUME /mnt/volumes/source
EXPOSE 8080/tcp
WORKDIR /home/$USER
