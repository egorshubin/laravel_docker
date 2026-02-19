#!/bin/bash
set -e

echo "Creating supervisor directories for Octane..."

# Create required directories
mkdir -p /var/www/storage/supervisor
mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/storage/framework/cache

# Ensure proper permissions
chmod -R 775 /var/www/storage

echo "Starting Octane via Supervisor..."

# Start Supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/octane.conf
