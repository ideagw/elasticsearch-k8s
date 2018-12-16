FROM docker.elastic.co/kibana/kibana:6.3.2
COPY enhanced-table-0.8.1_6.3.2.zip /tmp/
RUN kibana-plugin install file:///tmp/enhanced-table-0.8.1_6.3.2.zip
