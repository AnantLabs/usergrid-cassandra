#
# Cassandra Dockerfile for Usergrid
#
# https://github.com/yep/usergrid-cassandra
# 

FROM usergrid-java

ENV DEBIAN_FRONTEND noninteractive
#ENV CASSANDRA_VERSION 2.2.13
WORKDIR /root

RUN \
	curl https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh > install.sh && \
	bash install.sh && \
	wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb && \
	dpkg -i python-support_1.0.15_all.deb


# add datastax repository and install cassandra
RUN \
  echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list && \
  curl https://debian.datastax.com/debian/repo_key | apt-key add -  && \
  apt-get update && \
  apt-get update -o Dir::Etc::sourcelist="sources.list.d/cassandra.sources.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" && \
  apt-get install -yq cassandra=1.2.18 net-tools && \
  sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/" /etc/cassandra/cassandra.yaml && \
  rm -rf /var/lib/apt/lists/*

# persist database and logs between container starts
VOLUME ["/var/lib/cassandra", "/var/log/cassandra"]

# set default command when starting container with "docker run"
#CMD /root/run.sh

# available ports:
#  7000 intra-node communication
#  7001 intra-node communication over tls
#  7199 jmx
#  9042 cassandra native transport (cassandra query language, cql)
#  9160 cassandra thrift interface (legacy)
EXPOSE 9042 9160

COPY run.sh /root/run.sh
RUN chmod 777 /root/run.sh
CMD /root/run.sh 
