# VERSION 1.0.0
# AUTHOR: Liyuan Luo

FROM python:3.7.10-stretch
LABEL maintainer="liyuan"

ARG SPARK_VERSION="2.4.5"
ARG HADOOP_VERSION="2.7"


USER root
###############################
## Begin JAVA installation
###############################
# Java is required in order to spark-submit work
# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y gnupg2 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB9B1D8886F44E2A && \
    add-apt-repository "deb http://security.debian.org/debian-security stretch/updates main" && \ 
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    pip freeze && \
    java -version $$ \
    javac -version

# Setup JAVA_HOME 
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN export JAVA_HOME
###############################
## Finish JAVA installation
###############################

###############################
## SPARK files and variables
###############################
ENV SPARK_HOME /usr/local/spark



# Spark submit binaries and jars (Spark binaries must be the same version of spark cluster)
RUN cd "/tmp" && \
        wget --no-verbose "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
        tar -xvzf "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
        mkdir -p "${SPARK_HOME}/bin" && \
        mkdir -p "${SPARK_HOME}/assembly/target/scala-2.12/jars" && \
        cp -a "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/bin/." "${SPARK_HOME}/bin/" && \
        cp -a "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/jars/." "${SPARK_HOME}/assembly/target/scala-2.12/jars/" && \
        rm "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

# Create SPARK_HOME env var
RUN export SPARK_HOME
ENV PATH $PATH:/usr/local/spark/bin
###############################
## Finish SPARK files and variables
###############################


###############################
## jupyter and toree
###############################
RUN pip install -U pip setuptools wheel -i https://pypi.douban.com/simple \
    && pip install jupyter -i https://pypi.douban.com/simple \
	&& pip install jupyter lab -i https://pypi.douban.com/simple \
    && pip install toree -i https://pypi.douban.com/simple \
    && jupyter toree install --spark_home=/usr/local/spark \
    && mkdir /root/jupyter \
	&& mkdir /root/jupyter/data \
	&& mkdir /root/jupyter/ipynb

################################


USER root
WORKDIR /root/jupyter
CMD ["/bin/bash"]