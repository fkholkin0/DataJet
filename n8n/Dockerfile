ARG NODE_VERSION=18
FROM n8nio/base:${NODE_VERSION}

ARG PYTHON_VERSION=3.11.4

# install build dependencies and needed tools
RUN apk update
RUN apk add automake g++ subversion python3-dev \
		wget \
		gcc \
		make \
		zlib-dev \
		libffi-dev \
		openssl-dev \
		musl-dev

# download and extract python sources
RUN cd /opt \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \                                              
    && tar xzf Python-${PYTHON_VERSION}.tgz

# build python and remove left-over sources
RUN cd /opt/Python-${PYTHON_VERSION} \ 
    && ./configure --prefix=/usr --enable-optimizations --with-ensurepip=install \
    && make install \
    && rm /opt/Python-${PYTHON_VERSION}.tgz /opt/Python-${PYTHON_VERSION} -rf

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install fire


ARG N8N_VERSION=1.1.0
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

ENV N8N_VERSION=${N8N_VERSION}
ENV NODE_ENV=production
RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
	'armv7') apk --no-cache add --virtual build-dependencies python3 build-base;; \
	esac && \
	npm install -g --omit=dev n8n@${N8N_VERSION} && \
	case "$apkArch" in \
	'armv7') apk del build-dependencies;; \
	esac && \
	find /usr/local/lib/node_modules/n8n -type f -name "*.ts" -o -name "*.js.map" -o -name "*.vue" | xargs rm && \
	rm -rf /root/.npm

COPY docker-entrypoint.sh /

RUN \
	mkdir .n8n && \
	chown node:node .n8n

USER node

RUN mkdir ~/.n8n/custom && cd ~/.n8n/custom && npm install n8n-nodes-python

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]