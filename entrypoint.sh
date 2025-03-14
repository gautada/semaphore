#!/bin/sh
#
# entrypoint: Located at `/etc/container/entrypoint` this script is the custom
#             entry for a container as called by `/usr/bin/container-entrypoint` set
#             in the upstream [alpine-container](https://github.com/gautada/alpine-container).
#             The default template is kept in
#             [gist](https://gist.github.com/gautada/f185700af585a50b3884ad10c2b02f98)

container_version() {
 /usr/bin/semaphore version | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
}

container_entrypoint() {
 tail -f /dev/null
 # /opt/semaphore/semaphore server --config /home/semaphore/config.json
}
