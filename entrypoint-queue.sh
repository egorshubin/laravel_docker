#!/bin/bash
set -e

# Create required directories with proper permissions
mkdir -p /var/www/storage/supervisor
mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/storage/framework/cache

# Ensure proper permissions
chmod -R 775 /var/www/storage

# Start Supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
