#########################################################################################################
# Install dependencies
#########################################################################################################
FROM nginx:latest
LABEL maintainer="marcus <marcus.oj.hallberg@gmail.com>"
RUN apt-get update && \
       apt-get install -y --no-install-recommends apt-utils && \
       apt-get -y install procps && \
       apt-get -y install sudo

### for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/Europe select Stockholm" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    apt-get update && \
    apt-get install -y git golang-go python3 python3-pip dnsutils vim 
#########################################################################################################
# Add customizations
#########################################################################################################
RUN mkdir /scripts
COPY image_files/attacker/scripts/actions.sh /scripts/actions.sh
COPY image_files/attacker/scripts/cmds.py /scripts/cmds.py
COPY image_files/attacker/requirements.txt /scripts/requirements.txt

WORKDIR /scripts

RUN chmod a+x actions.sh
RUN chmod a+x cmds.py
RUN python3 -m pip install -r requirements.txt
