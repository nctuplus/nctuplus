FROM ruby:2.3.2
ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y nodejs \
                       libgmp3-dev \
                       --no-install-recommends && \
rm -rf /var/lib/apt/lists/*

ENV APP_ROOT /workspace
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
COPY . $APP_ROOT

RUN bundle install

CMD ["rails", "server", "-b", "0.0.0.0"]
