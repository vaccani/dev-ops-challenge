# FROM ruby:2.6.2-stretch

# # Copy application code
# COPY . /application
# # Change to the application's directory
# WORKDIR /application

# # Set Rails environment to dev
# ENV RAILS_ENV development

# # precompile the assets
# RUN bundle install 

# # Start the application server

# ENTRYPOINT ["./entrypoint.sh"]

# EXPOSE 3000

# CMD ["rails", "server", "-b", "0.0.0.0"]

FROM ruby:2.3-slim

ARG appDir=/app

WORKDIR $appDir

RUN apt-get update
RUN mkdir -p \
    /usr/share/man/man1 \
    /usr/share/man/man7
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -f \
    ruby-dev \
    ruby-execjs \
    gcc \
    libffi-dev \
    make \
    patch \
    postgresql-client-9.6 \
    libpq-dev
RUN apt-get -y autoremove; apt-get -y clean; apt-get -y autoclean

# Drop privileges
RUN adduser --disabled-password --gecos "" app
COPY --chown=app:app . .

USER app
WORKDIR $appDir

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN bundle config --delete frozen

RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
