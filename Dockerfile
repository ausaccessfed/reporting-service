ARG BASE_IMAGE=""
FROM ${BASE_IMAGE} as base
COPY .FORCE_NEW_DOCKER_BUILD  .FORCE_NEW_DOCKER_BUILD

ENV TORBA_HOME_PATH=/app/.torba
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

USER app

RUN mkdir -p ./public/assets \
    sockets \
    tmp/pids

USER root

RUN yum install -y \
    jq \
    && yum -y clean all \
    && rm -rf /var/cache/yum

EXPOSE 3000

ENTRYPOINT ["/app/bin/boot.sh"]
CMD ["bundle exec unicorn -c config/unicorn.rb -p $PORT"]

FROM base as geckodriver
RUN yum -y update \
    && yum -y install \
        tar \
        wget \
    && yum -y clean all \
    && rm -rf /var/cache/yum

RUN export gecko_version='0.32.0' \
    && export arch="$([ "$(rpm --eval '%{_arch}')" = "aarch64" ] && echo "linux-aarch64" || echo "linux64")" \
    && wget https://github.com/mozilla/geckodriver/releases/download/v${gecko_version}/geckodriver-v${gecko_version}-${arch}.tar.gz \
    && tar -zxvf geckodriver-v${gecko_version}-${arch}.tar.gz \
    && mv geckodriver /usr/local/bin/ \
    && rm geckodriver-v${gecko_version}-${arch}.tar.gz
FROM base as dependencies

RUN yum -y update \
    && yum -y install epel-release \
    && yum install -y \
    --enablerepo=devel \
    libtool \
    make \
    automake \
    ImageMagick-devel \
    firefox \
    gcc \
    gcc-c++ \
    xz \
    kernel-devel \
    mysql-devel \
    procps \
    && yum -y clean all \
    && rm -rf /var/cache/yum

USER app

COPY --chown=app ./Gemfile ./Gemfile.lock ./

## is installing production gems
RUN bundle install \
    && rbenv rehash

COPY --from=geckodriver /usr/local/bin/geckodriver /usr/local/bin/geckodriver

COPY --chown=app  ./Torbafile ./

RUN secret_key_base=1 bundle exec torba pack

## needed for precompile to run with prebuilt assets
COPY --chown=app ./config ./config
COPY --chown=app ./Rakefile ./Rakefile
COPY --chown=app ./lib ./lib
COPY --chown=app ./app/helpers ./app/helpers
COPY --chown=app ./app/controllers/application_controller.rb ./app/controllers/application_controller.rb

RUN BUILD=true SECRET_KEY_BASE=TempSecretKey bundle exec rake assets:precompile

FROM dependencies as development
ENV RAILS_ENV development
ARG LOCAL_BUILD=false

USER root

RUN bundle config set --local without "non_docker"

RUN [ "${LOCAL_BUILD}" == "true" ] && bundle config set --local force_ruby_platform true || echo "not local"

USER app

RUN bundle install \
    && rbenv rehash

COPY --chown=app . .

ARG RELEASE_VERSION="VERSION_PROVIDED_ON_BUILD"
ENV RELEASE_VERSION $RELEASE_VERSION

FROM base as production
USER app

COPY --from=dependencies /opt/.rbenv /opt/.rbenv
COPY --from=dependencies ${APP_DIR}/public ${APP_DIR}/public
COPY --from=dependencies /usr/lib64/mysql \
    /usr/lib64/libprocps.so.8 \
    /usr/lib64/libm.so.6 \
    /usr/lib64/liblz4.so.1 \
    /usr/lib64/liblzma.so.5 \
    /usr/lib64/libjpeg.so.62 \
    /usr/lib64/libIlmThread-3_1.so.30 \
    /usr/lib64/libMagickCore-6.Q16.so.7 \
    /usr/lib64/liblcms2.so.2 \
    /usr/lib64/libraqm.so.0 \
    /usr/lib64/liblqr-1.so.0 \
    /usr/lib64/libglib-2.0.so.0 \
    /usr/lib64/libxml2.so.2 \
    /usr/lib64/libfontconfig.so.1 \
    /usr/lib64/libfreetype.so.6 \
    /usr/lib64/libXext.so.6 \
    /usr/lib64/libSM.so.6 \
    /usr/lib64/libICE.so.6 \
    /usr/lib64/libX11.so.6 \
    /usr/lib64/libXt.so.6 \
    /usr/lib64/libbz2.so.1 \
    /usr/lib64/libz.so.1  \
    /usr/lib64/libltdl.so.7 \
    /usr/lib64/libgomp.so.1  \
    /usr/lib64/libgcc_s.so.1 \
    /usr/lib64/libcrypt.so.2  \
    /usr/lib64/libharfbuzz.so.0\
    /usr/lib64/libfribidi.so.0 \
    /usr/lib64/libpcre.so.1 \
    /usr/lib64/liblzma.so.5 \
    /usr/lib64/libpng16.so.16 \
    /usr/lib64/libbrotlidec.so.1 \
    /usr/lib64/libuuid.so.1 \
    /usr/lib64/libxcb.so.1 \
    /usr/lib64/libgraphite2.so.3 \
    /usr/lib64/libbrotlicommon.so.1 \
    /usr/lib64/libXau.so.6 \
    /usr/lib64/libMagickWand-6.Q16.so.7 \
    /usr/lib64/
COPY --from=dependencies /usr/local/bundle /usr/local/bundle
COPY --from=dependencies /usr/sbin/pidof /usr/sbin/pidof
COPY --from=dependencies ${APP_DIR}/.torba ${APP_DIR}/.torba

COPY --chown=app . .

RUN rm -rf spec \
    node_modules \
    docs \
    .yarn \
    .cache \
    /usr/local/bundle/cache/*.gem \
    tmp/cache \
    vendor/assets \
    lib/assets

ARG RELEASE_VERSION="VERSION_PROVIDED_ON_BUILD"
ENV RELEASE_VERSION $RELEASE_VERSION
