FROM debian:stretch-slim
MAINTAINER vvakame

ADD . /work
WORKDIR /work

ENV LANG en_US.UTF-8

# noto files from kmuto.jp server
ADD https://kmuto.jp/debian/noto/noto-map.tgz /tmp/noto-map.tgz
RUN mkdir -p /etc/texmf/texmf.d && echo "TEXMFVAR=/work/.texmf-var" > /etc/texmf/texmf.d/99local.cnf
RUN mkdir -p /usr/share/texlive/texmf-dist/fonts/map/dvipdfmx/ptex-fontmaps && cd /usr/share/texlive/texmf-dist/fonts/map/dvipdfmx/ptex-fontmaps && tar zxvf /tmp/noto-map.tgz && rm /tmp/noto-map.tgz

ADD https://kmuto.jp/debian/noto/fonts-noto-cjk_1.004+repack3-1~exp1_all.deb /tmp/noto.deb
# download from local dir
#ADD fonts-noto-cjk_1.004+repack3-1~exp1_all.deb /tmp/noto.deb
RUN dpkg -i /tmp/noto.deb && rm /tmp/noto.deb

# better for JP region
RUN echo "deb http://ftp.jp.debian.org/debian stretch main" > /etc/apt/sources.list

# setup
RUN apt-get update
RUN apt-get install -y locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen en_US.UTF-8
RUN update-locale en_US.UTF-8
RUN apt-get install -y git-core curl

# install Re:VIEW environment
RUN apt-get install -y --no-install-recommends curl texlive-lang-japanese texlive-fonts-recommended texlive-latex-extra ghostscript ghostscript gsfonts poppler-data ruby-zip ruby-nokogiri ruby-mecab mecab mecab-ipadic-utf8 git-core && apt-get upgrade -y --no-install-recommends && apt-get clean

RUN kanji-config-updmap-sys noto
RUN gem install review review-peg bundler rake --no-rdoc --no-ri

# install node.js environment
RUN apt-get install -y gnupg
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs
