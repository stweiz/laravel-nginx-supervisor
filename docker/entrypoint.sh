#!/bin/sh

cd /var/www/app
php artisan migrate --force
supervisord --nodaemon --configuration /var/www/app/docker/supervisord/supervisor.conf
