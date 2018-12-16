#!/bin/sh

echo "Starting Elasticsearch ${ES_VERSION}"

BASE=/usr/share/elasticsearch

# Allow for memlock if enabled
if [ "${MEMORY_LOCK}" == "true" ]; then
    ulimit -l unlimited
fi

# Set a random node name if not set
if [ -z "${NODE_NAME}" ]; then
    NODE_NAME="$(uuidgen)"
fi

export ES_TMPDIR="$(mktemp -d -t elasticsearch.XXXXXXXX)"

# Prevent "Text file busy" errors
sync

if [ ! -z "${ES_PLUGINS_INSTALL}" ]; then
    OLDIFS="${IFS}"
    IFS=","
    for plugin in ${ES_PLUGINS_INSTALL}; do
        if ! "${BASE}"/bin/elasticsearch-plugin list | grep -qs ${plugin}; then
            until "${BASE}"/bin/elasticsearch-plugin install --batch ${plugin}; do
                echo "Failed to install ${plugin}, retrying in 3s"
                sleep 3
            done
        fi
    done
    IFS="${OLDIFS}"
fi

# Run
if [[ $(whoami) == "root" ]]; then
    if [ ! -d "/data/data/nodes/0" ]; then
        echo "Changing ownership of /data folder"
        chown -R elasticsearch:elasticsearch /data
    fi
    exec su elasticsearch /usr/local/bin/docker-entrypoint.sh  
else
    /usr/local/bin/docker-entrypoint.sh
fi
