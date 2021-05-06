
# Docker image for a Laravel app and nginx in supervisord

This image is a preparation to run Laravel workers and also an Laravel application.
The application runs in PHP 8.0 with FastCGI in Alpine linux and MySQL drivers are prepared.

## Supervisor and nginx configuration

The configuration is generic and for one application, but should work with most apps. If not, copy your own configuration in your build or send
me a pull request or message with your wish.

Note: The Laravel worker has its queue locally. This means:

- You should only run one instance and don't scale the service.
- After a new deployment, crash etc. the queue is not available anymore.

## Setup

1. Create a Dockerfile in your project, which looks like this:

```
FROM bausparkadse/laravel-nginx-supervisor:<version>

COPY . .
RUN composer install && chown -R www-data:www-data .
```

2. Your project tree should look like this from the root:

```
├── app
├── artisan
├── bootstrap
├── composer.json
├── composer.lock
├── config
├── database
├── Dockerfile <- This is the new Dockerfile.
├── phpunit.xml
├── public
│   ├── favicon.ico
│   ├── index.php
│   ├── robots.txt
│   ├── vendor
│   └── web.config
├── README.md
├── resources
├── routes
├── server.php
├── storage
└── tests
```

3. Build an image of your project:

`docker build -t your-project-image .`

4. Run it like this, so it can connect to your MySQL server, which is exposed to the host system:

`docker run --name your-project-container --rm --network="host" your-project-image`

5. Run migrations:

`docker exec your-project-container php artisan migrate`

Migrations are not ran automatically, because you shouldn't do it in Laravael production mode. So it must be done manually within the Docker container.

## Used software

- Alpine Linux
- PHP 8.0 with FastCGI
- PHP-MySQL
- Composer
- nginx
