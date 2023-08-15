FROM postgres:15

RUN apt-get update && \
apt-get install build-essential gcc make cmake postgresql-server-dev-15 libcurl4-openssl-dev uuid-dev -y && \
apt-get install --reinstall pkg-config cmake-data -y

COPY ./extentions/clickhouse_fdw /tmp/clickhouse_fdw
RUN mkdir /tmp/clickhouse_fdw/build
RUN cd /tmp/clickhouse_fdw/build && cmake .. && make && make install

COPY ./extentions/pg_net /tmp/pg_net
RUN cd /tmp/pg_net && make && make install