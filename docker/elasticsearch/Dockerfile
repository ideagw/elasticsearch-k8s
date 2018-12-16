FROM docker.elastic.co/elasticsearch/elasticsearch:6.3.0

MAINTAINER Rakesh Jain rakeshj@us.ibm.com

# Set environment variables defaults
ENV ES_JAVA_OPTS "-Xms512m -Xmx512m"
ENV CLUSTER_NAME elasticsearch-default
ENV NODE_MASTER true
ENV NODE_DATA true
ENV NODE_INGEST true
ENV NODE_ML false
ENV HTTP_ENABLE true
ENV NETWORK_HOST _site_
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV NUMBER_OF_MASTERS 1
ENV MAX_LOCAL_STORAGE_NODES 1
ENV SHARD_ALLOCATION_AWARENESS ""
ENV SHARD_ALLOCATION_AWARENESS_ATTR ""
ENV REPO_LOCATIONS ""
ENV MEMORY_LOCK true
ENV LICENSE basic
ENV XPACK_SECURITY_ENABLED false

# kubernetes
ENV DISCOVERY_SERVICE elasticsearch-discovery

# Copy configuration
COPY config /usr/share/elasticsearch/config

# Copy run script
COPY run.sh /

CMD ["/run.sh"]
