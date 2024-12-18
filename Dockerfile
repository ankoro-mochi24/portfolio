FROM ruby:3.3.0

ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

# 必要なパッケージをインストール
RUN apt-get update -qq \
  && apt-get install -y ca-certificates curl gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && NODE_MAJOR=18 \
  && wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y build-essential libpq-dev libssl-dev nodejs yarn python3 cron graphviz

# 作業ディレクトリの作成
RUN mkdir -p /v3_advanced_rails/tmp/pids
WORKDIR /v3_advanced_rails

# Bundlerのインストール
RUN gem install bundler --no-document

# プラットフォーム依存のgemをインストール
RUN gem install bcrypt --platform ruby
RUN gem install ffi --platform ruby
RUN gem install msgpack --platform ruby
RUN gem install nio4r --platform ruby

# GemfileとGemfile.lockのコピー
COPY Gemfile /v3_advanced_rails/Gemfile
COPY Gemfile.lock /v3_advanced_rails/Gemfile.lock

# bundle install
RUN bundle install

# Yarnのインストール
RUN yarn install

# アセットのプリコンパイル
COPY . /v3_advanced_rails
RUN bundle exec rake assets:precompile RAILS_ENV=production

# Pumaの起動
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
