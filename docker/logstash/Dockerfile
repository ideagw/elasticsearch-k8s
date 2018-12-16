FROM docker.elastic.co/logstash/logstash:6.3.2
RUN logstash-plugin install logstash-filter-uuid
RUN logstash-plugin install logstash-input-log4j
RUN logstash-plugin install logstash-input-lumberjack
RUN logstash-plugin install logstash-output-statsd
