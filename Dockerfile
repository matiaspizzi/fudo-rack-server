FROM ruby:3.4.7-trixie

WORKDIR /app
COPY . .

RUN bundle install

EXPOSE 9292

CMD ["rackup", "--host", "0.0.0.0"]