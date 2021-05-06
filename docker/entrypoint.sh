#!/bin/sh

cd /var/www/app
php artisan migrate --no-interaction
supervisord --nodaemon --configuration /var/www/app/docker/supervisord/supervisor.conf
