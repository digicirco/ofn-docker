Download this folder, 

`docker compose up`

then run the following commands to create and populate database

* `docker-compose run ofn bundle exec rake db:create`
* `docker-compose run ofn bundle exec rake db:schema:load`
* `docker-compose run ofn bundle exec rake db:migrate`
* `docker-compose run ofn bundle exec rake db:seed` for initial admin user
* `docker-compose run ofn bundle exec rake ofn:sample_data` for sample data

At the moment, the image is 1.7GB (far too big). Same image for app and webpack (don't know if it makes sense). I find OFN a bit slow even if it's running on local ...

Go to ofn.localhost in your browser ;) 