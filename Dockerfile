FROM ruby:2.3.3
RUN apt-get update -qq
RUN apt-get install -y build-essential
RUN apt-get install -y libpq-dev
RUN apt-get install -y nodejs

# for capybara-webkit
RUN apt-get install -y libqt5webkit5-dev
RUN apt-get install -y qt5-default
RUN apt-get install -y gstreamer1.0-plugins-base
RUN apt-get install -y gstreamer1.0-tools
RUN apt-get install -y gstreamer1.0-x
RUN apt-get install -y xvfb

# for nokogiri
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libxslt1-dev

RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp