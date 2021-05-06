#!/bin/sh

php artisan migrate
supervisord --nodaemon --configuration /var/www/app/docker/supervisord/supervisor.conf
