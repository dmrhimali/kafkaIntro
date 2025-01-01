FROM confluentinc/cp-kafka-connect-base:5.5.0

RUN confluent-hub install --no-prompt debezium/debezium-connector-postgresql:1.1.0
RUN confluent-hub install --no-prompt debezium/debezium-connector-sqlserver:1.1.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:5.5.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:5.5.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:5.5.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-aws-redshift:1.0.2
RUN confluent-hub install --no-prompt jcustenborder/kafka-connect-redis:0.0.2.11
RUN confluent-hub install --no-prompt confluentinc/connect-transforms:1.3.2
