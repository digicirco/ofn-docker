Download this folder, 

`docker compose up`

then run the following commands to create and populate database

* `docker-compose run ofn bundle exec rake db:create`
* `docker-compose run ofn bundle exec rake db:schema:load`
* `docker-compose run ofn bundle exec rake db:migrate`
* `docker-compose run ofn bundle exec rake db:seed` for initial admin user
* `docker-compose run ofn bundle exec rake ofn:sample_data` for sample data
* `bundle exec rake assets:precompile` **inside container** to precompile assets (but does not seem to make the app faster)

At the moment, the image is 1.7GB (far too big). I find OFN a bit slow even if it's running on local ...

Go to ofn.localhost in your browser ;) 