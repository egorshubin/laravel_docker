FROM dunglas/frankenphp:php8.5

# Switch to root to install system packages
USER root

# Install system dependencies including Supervisor and cron
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    supervisor \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions using the provided install-php-extensions script
RUN install-php-extensions \
    gd \
    pdo_mysql \
    mysqli \
    zip \
    pcntl \
    bcmath \
    sockets \
    opcache \
    imagick \
    redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create non-root user
RUN groupadd -g 1000 laravel \
    && useradd -u 1000 -g laravel -m -s /bin/bash laravel

# Set working directory
WORKDIR /var/www

# Copy entrypoint scripts from project root
COPY entrypoint-queue.sh /usr/local/bin/entrypoint-queue.sh
COPY entrypoint-octane.sh /usr/local/bin/entrypoint-octane.sh
RUN chmod +x /usr/local/bin/entrypoint-queue.sh /usr/local/bin/entrypoint-octane.sh

# Set ownership
RUN mkdir -p /var/www/storage/logs /var/www/storage/supervisor /var/www/bootstrap/cache \
    && chown -R laravel:laravel /var/www

# Switch to non-root user
USER laravel

EXPOSE 8000

# Keep container running without starting Octane
CMD ["tail", "-f", "/dev/null"]
