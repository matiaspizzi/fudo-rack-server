### To run this project (manually):

1. [Install Ruby](https://www.ruby-lang.org/es/documentation/installation/). This project was built on version 3.4.7

2. Install bundle: `gem install bundle`

3. Install gems: `bundle install`

4. Set env variables for db connection

5. Migrate the database: `rake db:migrate`

6. Start the server: `rackup`

### Using Docker:

1. Build the image: `docker build . -f Dockerfile -t rack:latest`

2. Start the application: `docker run -p 9292:9292 rack:latest`