
FROM registry.astralinux.ru/astra/ubi18 AS documentserver
LABEL maintainer Ascensio System SIA <support@onlyoffice.com>

ARG BASE_VERSION
ARG PG_VERSION=16
ARG PACKAGE_SUFFIX=t64

ENV OC_RELEASE_NUM=21
ENV OC_RU_VER=12
ENV OC_RU_REVISION_VER=0
ENV OC_RESERVED_NUM=0
ENV OC_RU_DATE=0
ENV OC_PATH=${OC_RELEASE_NUM}${OC_RU_VER}000
ENV OC_FILE_SUFFIX=${OC_RELEASE_NUM}.${OC_RU_VER}.${OC_RU_REVISION_VER}.${OC_RESERVED_NUM}.${OC_RU_DATE}${OC_FILE_SUFFIX}dbru
ENV OC_VER_DIR=${OC_RELEASE_NUM}_${OC_RU_VER}
ENV OC_DOWNLOAD_URL=https://download.oracle.com/otn_software/linux/instantclient/${OC_PATH}

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive PG_VERSION=${PG_VERSION} BASE_VERSION=${BASE_VERSION}

ARG ONLYOFFICE_VALUE=onlyoffice

#RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d 



COPY config/supervisor/ds/*.conf /etc/supervisor/conf.d/
COPY run-document-server.sh /app/ds/run-document-server.sh
COPY oracle/sqlplus /usr/bin/sqlplus
COPY onlyoffice-documentserver_8.3.2-3_amd64.deb /
COPY ttf-mscorefonts-installer_3.6_all.deb /

EXPOSE 80 443

ARG COMPANY_NAME=onlyoffice
ARG PRODUCT_NAME=documentserver
ARG PRODUCT_EDITION=
ARG PACKAGE_VERSION=
ARG TARGETARCH
ARG PACKAGE_BASEURL="http://download.onlyoffice.com/install/documentserver/linux"

ENV COMPANY_NAME=$COMPANY_NAME \
    PRODUCT_NAME=$PRODUCT_NAME \
    PRODUCT_EDITION=$PRODUCT_EDITION \
    DS_PLUGIN_INSTALLATION=false \
    DS_DOCKER_INSTALLATION=true

RUN     apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive DS_DOCKER_INSTALLATION=1 apt-get install  /ttf-mscorefonts-installer_3.6_all.deb \
    netcat-openbsd /onlyoffice-documentserver_8.3.2-3_amd64.deb unzip cron libaio1 libboost-regex-dev libnspr4 libnss3 net-tools sudo supervisor unixodbc-dev -y  && \
    chmod 755 /etc/init.d/supervisor && \
    sed "s/COMPANY_NAME/${COMPANY_NAME}/g" -i /etc/supervisor/conf.d/*.conf && \
    service supervisor stop && \
    chmod 755 /app/ds/*.sh && \
#    printf "\nGO" >> "/var/www/$COMPANY_NAME/documentserver/server/schema/mssql/createdb.sql" && \
#    printf "\nGO" >> "/var/www/$COMPANY_NAME/documentserver/server/schema/mssql/removetbl.sql" && \
#    printf "\nexit" >> "/var/www/$COMPANY_NAME/documentserver/server/schema/oracle/createdb.sql" && \
#    printf "\nexit" >> "/var/www/$COMPANY_NAME/documentserver/server/schema/oracle/removetbl.sql" && \
    rm -f /onlyoffice-documentserver_8.3.2-3_amd64.deb && \
    rm -rf /var/log/$COMPANY_NAME && \
    rm -rf /var/lib/apt/lists/*
    COPY config/supervisor/supervisor /etc/init.d/
VOLUME /var/log/$COMPANY_NAME /var/lib/$COMPANY_NAME /var/www/$COMPANY_NAME/Data /var/lib/postgresql /var/lib/rabbitmq /var/lib/redis /usr/share/fonts/truetype/custom

ENTRYPOINT ["/app/ds/run-document-server.sh"]
