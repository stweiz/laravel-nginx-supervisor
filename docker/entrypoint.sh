#!/bin/sh

supervisord --nodaemon --configuration /var/www/app/docker/supervisord/supervisor.conf
