FROM ruby:3.0.2-buster

ADD . mindproxy/

RUN cd mindproxy && \
	bundle install && \
	chmod +x mindproxy.rb
ENTRYPOINT mindproxy/mindproxy.rb
