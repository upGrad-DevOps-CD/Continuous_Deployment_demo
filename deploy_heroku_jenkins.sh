#!/bin/bash
set -x
heroku container:login
#login to container
heroku container:push web -a democicdapp
#push the docker image
heroku container:release web -a democicdapp
# release the application
heroku info -a democicdapp
#get info about application