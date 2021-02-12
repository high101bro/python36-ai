ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/python/python36
ARG BASE_TAG=3.6
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

RUN mkdir /tmp/repo

COPY *.whl /tmp/repo
COPY *.tar.gz /tmp/repo

# need to be root to install rpm files
USER root

RUN yum update -y && \ 
    yum upgrade -y && \
    yum clean all -y && \
    yum install -y \
        git \
        vim \
        zip \
        unzip \
        wget \
        net-tools\
        # gcc is needed for fbprophet
        gcc-c++

# changing from root to default user 
USER default

RUN python3.6 -m pip install --upgrade --no-index --find-links /tmp/repo pip && \
    python3.6 -m pip install --no-index --find-links /tmp/repo \
        plotly \
        pandas \
        matplot \
        seaborn \
        numpy \
        scipy \
        scikit-learn \
        tdqm \
        urllib3 \
        requests \
        beautifulsoup4 \
        wordcloud \
        statsmodels \
        fbprophet  \
        django \
        flask

# clean up
RUN rm -rf /tmp/repo

HEALTHCHECK --interval=10s --timeout=1s CMD python.3.6 -c 'print("up")' || exit 1

