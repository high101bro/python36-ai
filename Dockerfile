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
        vim \
        zip \
        unzip \
        wget \
        net-tools\
        # gcc is needed for fbprophet
        gcc-c++ \
        sudo \
        git


# changing from root to default user 
USER default

RUN python3.6 -m pip install --upgrade --no-index --find-links /tmp/repo pip && \
    python3.6 -m pip install --no-index --find-links /tmp/repo \
        plotly \
        pandas \
        matplot \
        seaborn \
        numba \
        numpy \
        scipy \
        #import sklearn
        scikit-learn \
        tqdm \
        urllib3 \
        requests \
        #from bs4 import BeautifulSoup
        beautifulsoup4 \
        #from wordcloud import WordCloud
        wordcloud \
        statsmodels \
        fbprophet  \
        django \
        flask

USER root

# Allows Matplotlib to write to the directory. It is highly recommended to set the MPLCONFIGDIR environment variable to a writable directory, in particular to speed up the import of Matplotlib and to better support multiprocessing, otherwise it'll create a temporary config/cache direcotyr at /tmp/matplotlib-_ovd7aly.
RUN chown default /opt/app-root/src/

### Compliance Modification ###
# Upgrading to the version that was installed in pytho36 base
RUN yum upgrade -y \
    glibc-2.28-127.el8_3.2.x86_64 \
    glibc-common-2.28-127.el8_3.2.x86_64 \
    glibc-minimal-langpack-2.28-127.el8_3.2.x86_64

# Upgrading click to patched version
RUN python3.6 -m pip uninstall click -y && \
    rm -f /tmp/repo/click-7.1.2-py2.py3-none-any.whl && \
    python3.6 -m pip install --no-index --find-links /tmp/repo click


# Removing identified secret and SUID files
RUN rm -rf /usr/share/doc/perl-IO-Socket-SSL/certs/ && \
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/example/ && \
    rm -rf /usr/share/doc/perl-IO-Socket-SSL/example/ && \
    rm -rf /usr/share/doc/perl-Net-SSLeay/examples/server_key.pem && \
    chmod g-s /usr/libexec/openssh/ssh-keysign  

# NOTE: gcc
# gcc 8.3.1-5.1.el8 shows to be vulnerable when scanned, but is included in the base python36 image

RUN yum remove -y \
    #Medium - No Description available [6Jan21]
    binutils \
    #High - The maximum impact of this vulnerability is a crash, and it relies on processing untrusted input in an uncommon encoding (EUC-KR). When this encoding is not used, the vulnerability can not be triggered.
            #Mitigation for this issue is either not available or the currently available options do not meet the Red Hat Product Security criteria comprising ease of use and deployment, applicability to widespread installation base or stability.
    glibc-devel \
    #High - The maximum impact of this vulnerability is a crash, and it relies on processing untrusted input in an uncommon encoding (EUC-KR). When this encoding is not used, the vulnerability can not be triggered.
            #Mitigation for this issue is either not available or the currently available options do not meet the Red Hat Product Security criteria comprising ease of use and deployment, applicability to widespread installation base or stability.
    glibc-headers \
    #High - The maximum impact of this vulnerability is a crash, and it relies on processing untrusted input in an uncommon encoding (EUC-KR). When this encoding is not used, the vulnerability can not be triggered.
    glibc-langpack-en \
    #High
    kernel-headers

#    # git requires perl to be installed for it's functionality
#    #Medium - To mitigate this flaw, developers should not allow untrusted regular expressions to be compiled by the Perl regular expression compiler.
#    perl-interpreter \
#    #Medium - To mitigate this flaw, developers should not allow untrusted regular expressions to be compiled by the Perl regular expression compiler.
#    perl-libs \
#    #Medium - To mitigate this flaw, developers should not allow untrusted regular expressions to be compiled by the Perl regular expression compiler.
#    perl-macros


# clean up
RUN rm -rf /tmp/repo

USER default

HEALTHCHECK --interval=10s --timeout=1s CMD python.3.6 -c 'print("up")' || exit 1

