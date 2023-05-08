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
CMD ["bundle exec puma"]

# FROM base as aws-dependencies

# RUN yum install -y \
#     unzip \
#     && yum -y clean all \
#     && rm -rf /var/cache/yum

# RUN export arch=$(rpm --eval '%{_arch}') \
#     && curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip" \
#     && unzip -q awscliv2.zip \
#     && ./aws/install \
#     && rm awscliv2.zip \
#     && rm -rf aws

# FROM base as js-dependencies

# RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash - \
#     && curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
#     && rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg \
#     && yum -y install epel-release \
#     && yum remove libuv -y \
#     && yum install -y nodejs yarn --disableplugin=priorities \
#     && yum -y clean all \
#     && rm -rf /var/cache/yum

# USER app

# COPY --chown=app ./package.json ./yarn.lock ./.yarnrc.yml ./webpack.config.js ./
# COPY --chown=app ./.yarn ./.yarn
# RUN yarn install

# COPY --chown=app ./babel.config.js ./postcss.config.js ./

# COPY --chown=app ./app/components ./app/components
# COPY --chown=app ./app/views ./app/views
# COPY --chown=app ./app/helpers ./app/helpers
# COPY --chown=app ./app/decorators ./app/decorators
# COPY --chown=app ./app/assets ./app/assets

# COPY --chown=app ./app/frontend ./app/frontend

# RUN yarn build

FROM base as dependencies

RUN yum -y update \
    && yum -y install epel-release \
    && yum install -y \
    --enablerepo=devel \
    libtool \
    make \
    automake \
    ImageMagick-devel \
    gcc \
    gcc-c++ \
    xz \
    chromium \
    kernel-devel \
    mysql-devel \
    procps \
    && yum -y clean all \
    && rm -rf /var/cache/yum

USER app
# COPY --chown=app --from=aws-dependencies /usr/local/aws-cli/v2/current/dist /tmp/aws
# COPY --chown=app --from=aws-dependencies /usr/local/aws-cli/v2/current/dist /usr/local/bin

COPY --chown=app ./Gemfile ./Gemfile.lock ./

## is installing production gems
RUN bundle install \
    && rbenv rehash

COPY --chown=app  ./Torbafile ./

RUN secret_key_base=1 bundle exec torba pack

# COPY --from=js-dependencies /app/app/assets ./app/assets
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

## needed for prettier to be runnable
# COPY --from=js-dependencies /usr/bin/node /usr/bin/yarn /usr/bin/
# COPY --from=js-dependencies /usr/share/yarn/bin/yarn.js /usr/bin/yarn.js
# COPY --from=js-dependencies /usr/share/yarn/lib/cli.js /usr/lib/cli
# COPY --from=js-dependencies /app/node_modules/ ./node_modules/

COPY --chown=app . .

ARG RELEASE_VERSION="VERSION_PROVIDED_ON_BUILD"
ENV RELEASE_VERSION $RELEASE_VERSION

FROM base as production
USER app

COPY --from=dependencies /opt/.rbenv /opt/.rbenv
COPY --from=dependencies ${APP_DIR}/public/assets ${APP_DIR}/public/assets
COPY --from=dependencies /usr/lib64/mysql /usr/lib64/mysql
# COPY --chown=app --from=dependencies /tmp/aws /usr/local/bin/
COPY --from=dependencies /usr/local/bundle /usr/local/bundle
COPY --from=dependencies /usr/sbin/pidof /usr/sbin/pidof
COPY --from=dependencies /usr/lib64/libprocps.so.8 /usr/lib64/libprocps.so.8

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
