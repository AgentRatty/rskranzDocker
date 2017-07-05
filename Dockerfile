FROM rocker/tidyverse

# News: Base now on rocker/rstudio since shiny is now supported

# based on skranz/shinyrstudio
# so we already have
# rstudio + shiny + tidverse R packages

MAINTAINER Sebastian Kranz "sebastian.kranz@uni-ulm.de"

RUN export ADD=shiny && bash /etc/cont-init.d/add

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  libv8-3.14-dev \ 

## gnupg is needed to add new key
RUN apt-get install -y gnupg2

## Install Java 
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee /etc/apt/sources.list.d/webupd8team-java.list \
    &&  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
      | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" \
        | /usr/bin/debconf-set-selections \
    && apt-get update \
    && apt-get install -y oracle-java8-installer \
    && update-alternatives --display java \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && R CMD javareconf

## make sure Java can be found in rApache and other daemons not looking in R ldpaths
RUN echo "/usr/lib/jvm/java-8-oracle/jre/lib/amd64/server/" > /etc/ld.so.conf.d/rJava.conf
RUN /sbin/ldconfig

## Install rJava package
RUN install2.r --error rJava \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

#COPY install.r /tmp/install.r
#RUN Rscript /tmp/install.r

# copy and run package installation file
COPY install_mailR.r /tmp/install_mailR.r
RUN Rscript /tmp/install_mailR.r
