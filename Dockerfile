ARG BASE_IMAGE=""
# Version is pinned via .ruby-version
# hadolint ignore=DL3006
FROM ${BASE_IMAGE} as base

WORKDIR $APP_DIR

COPY .FORCE_NEW_DOCKER_BUILD  .FORCE_NEW_DOCKER_BUILD

ENV TORBA_HOME_PATH=/app/.torba
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"
ENV APP_NAME="AAF Reporting Service"

USER app

RUN mkdir -p ./public/assets \
    sockets \
    tmp/pids

USER root

RUN yum -y update \
    && yum install -y \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    jq-1.6-15.el9 \
    && yum -y clean all \
    && rm -rf /var/cache/yum

EXPOSE 3000

ENTRYPOINT ["/app/bin/boot.sh"]
CMD ["bundle exec puma"]
USER app

FROM base as js-dependencies
USER root

RUN yum -y update \
    && update-crypto-policies --set DEFAULT:SHA1 \
    && yum install https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y \
    && yum install -y \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64/nodejs:16
    nodejs-16.20.1 \
    # renovate: datasource=yum repo=rocky-9-extras-x86_64
    epel-release-9-7.el9 \
    && update-crypto-policies --set DEFAULT \
    && yum install -y \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    yarnpkg-1.22.19-5.el9  \
    && yum -y clean all \
    && rm -rf /var/cache/yum

# use ldd to get required libs
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN ldd \
    /usr/bin/node \
    | tr -s "[:blank:]" "\n" | grep "^/" | sed "/\/usr\/bin\//d" | \
    xargs -I % sh -c "mkdir -p /\$(dirname deps%); cp % /deps%;"

USER app

COPY --chown=app ./package.json ./yarn.lock ./
RUN yarn install

FROM base as imagick-dependencies
USER root

RUN yum -y update \
    && yum -y install \
    # renovate: datasource=yum repo=rocky-9-extras-x86_64
    epel-release-9-7.el9 \
    && yum install -y \
    --enablerepo=devel \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    ImageMagick-devel-6.9.12.93-1.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    advancecomp-2.5-1.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    gifsicle-1.93-1.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    jhead-3.06.0.1-5.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    jpegoptim-1.5.5-1.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    pngcrush-1.8.13-9.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    optipng-0.7.8-1.el9 \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    pngquant-2.17.0-2.el9 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    libjpeg-turbo-utils-2.0.90-6.el9_1 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    libjpeg-turbo-2.0.90-6.el9_1 \
    && yum -y clean all \
    && rm -rf /var/cache/yum

# uses ldd to get all deps of imagick, remove anything thats /usr/bin
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN ldd \
    /usr/bin/mogrify \
    /usr/bin/convert \
    /usr/bin/pngcrush \
    /usr/bin/jpegoptim \
    /usr/lib64/libMagickCore-6.Q16.so.7 \
    /usr/lib64/libmagic.so.1 \
    # /usr/bin/libjpeg-turbo \
    # /usr/bin/libjpeg-turbo-utils \
    | tr -s "[:blank:]" "\n" | grep "^/" | sed "/\/usr\/bin\//d" | sed "/:/d"  | \
    xargs -I % sh -c "mkdir -p /\$(dirname deps%); cp % /deps%;"

USER app

FROM base as dependencies
USER root

RUN yum -y update \
    && yum -y install \
    # renovate: datasource=yum repo=rocky-9-extras-x86_64
    epel-release-9-7.el9 \
    && yum install -y \
    --enablerepo=devel \
    # renovate: datasource=yum repo=epel-9-everything-x86_64
    chromium-120.0.6099.224-1.el9 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    libtool-2.4.6-45.el9 \
    # renovate: datasource=yum repo=rocky-9-baseos-x86_64
    make-4.3-7.el9 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    automake-1.16.2-8.el9 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    gcc-11.4.1-2.1.el9 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    gcc-c++-11.4.1-2.1.el9 \
    # renovate: datasource=yum repo=rocky-9-baseos-x86_64
    xz-5.2.5-8.el9_0 \
    # renovate: datasource=yum repo=rocky-9-appstream-x86_64
    kernel-devel-5.14.0-362.18.1.el9_3 \
    # renovate: datasource=yum repo=rocky-9-crb-x86_64
    mysql-devel-8.0.32-1.el9_2 \
    # renovate: datasource=yum repo=rocky-9-baseos-x86_64
    procps-ng-3.3.17-13.el9 \
    && yum -y clean all \
    && rm -rf /var/cache/yum


##  Copy yarn, node for linting
COPY --from=js-dependencies /usr/bin/node /usr/lib/node_modules/npm/bin/npm /usr/bin/
COPY --from=js-dependencies /usr/lib/node_modules /usr/bin/node_modules
RUN ln -s /usr/bin/node_modules/yarn/bin/yarn /usr/bin/yarn
# TODO: we could save some space by being selective here
COPY --from=js-dependencies /app/node_modules/ ./node_modules/
COPY --from=js-dependencies /deps/lib64 /usr/lib64/

## Copy imagick deps
COPY --from=imagick-dependencies /usr/bin/convert \
    /usr/bin/mogrify \
    /usr/bin/
COPY --from=imagick-dependencies \
    /usr/lib64/libMagickCore-6.Q16.so \
    /usr/lib64/libMagickWand-6.Q16.so \
    /usr/lib64/
COPY --from=imagick-dependencies /usr/lib64/pkgconfig /usr/lib64/pkgconfig
COPY --from=imagick-dependencies /usr/include/ImageMagick-6 /usr/include/ImageMagick-6
COPY --from=imagick-dependencies /usr/lib64/ImageMagick-6.9.12 /usr/lib64/ImageMagick-6.9.12
COPY --from=imagick-dependencies /etc/ImageMagick-6 /etc/ImageMagick-6
COPY --from=imagick-dependencies /deps/lib64 /usr/lib64/

USER app

COPY --chown=app ./Gemfile ./Gemfile.lock ./Torbafile ./

## is installing production gems
RUN bundle install \
    && rbenv rehash

RUN secret_key_base=1 bundle exec torba pack

## needed for precompile to run with prebuilt assets
COPY --chown=app ./config ./config
COPY --chown=app ./Rakefile ./Rakefile
COPY --chown=app ./app/assets ./app/assets
COPY --chown=app ./lib ./lib
COPY --chown=app ./app/helpers ./app/helpers
COPY --chown=app ./app/controllers/application_controller.rb ./app/controllers/application_controller.rb

RUN BUILD=true SECRET_KEY_BASE=TempSecretKey bundle exec rake assets:precompile

FROM dependencies as development
ENV RAILS_ENV development
ARG LOCAL_BUILD=false

USER root

RUN bundle config set --local without "non_docker"

RUN [ "${LOCAL_BUILD}" = "true" ] && bundle config set --local force_ruby_platform true || echo "not local"

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
COPY --from=dependencies /usr/bin/node /usr/bin/

## Copy imagick deps
COPY --from=imagick-dependencies /usr/bin/convert \
    /usr/bin/mogrify \
    /usr/bin/

## Copy imagick deps
COPY --from=imagick-dependencies /usr/bin/convert \
    /usr/bin/mogrify \
    /usr/bin/
COPY --from=imagick-dependencies \
    /usr/lib64/libMagickCore-6.Q16.so \
    /usr/lib64/libMagickWand-6.Q16.so \
    /usr/lib64/
COPY --from=imagick-dependencies /usr/lib64/pkgconfig /usr/lib64/pkgconfig
COPY --from=imagick-dependencies /usr/include/ImageMagick-6 /usr/include/ImageMagick-6
COPY --from=imagick-dependencies /usr/lib64/ImageMagick-6.9.12 /usr/lib64/ImageMagick-6.9.12
COPY --from=imagick-dependencies /etc/ImageMagick-6 /etc/ImageMagick-6
COPY --from=imagick-dependencies /deps/lib64 /usr/lib64/

COPY --from=dependencies \
    /usr/lib64/mysql \
    /usr/lib64/libprocps.so.8 \
    /usr/lib64/
COPY --from=dependencies /usr/local/bundle /usr/local/bundle
COPY --from=dependencies /usr/sbin/pidof /usr/sbin/pidof
COPY --from=dependencies ${APP_DIR}/.torba ${APP_DIR}/.torba

COPY --chown=app . .

USER root

RUN rm -rf spec \
    node_modules \
    docs \
    .yarn \
    .cache \
    /usr/local/bundle/cache/*.gem \
    tmp/cache \
    vendor/assets \
    lib/assets \
    && find /opt/.rbenv/ -type f -regextype egrep -regex ".*(Dockerfile|docker-compose\.yml|\.vimrc)" -exec rm -f {} + \
    && find /opt/.rbenv/ -type d -regextype egrep -regex ".*(\.git|spec|dummy_rails|test\/rails_app)" -exec rm -rf {} + \
    # Fix for https://github.com/goodwithtech/dockle/blob/master/CHECKPOINT.md#cis-di-0008
    && find / -path /proc -prune -o -perm /u=s,g=s -type f -print -exec rm {} \;
USER app

ARG RELEASE_VERSION="VERSION_PROVIDED_ON_BUILD"
ENV RELEASE_VERSION $RELEASE_VERSION
