#!/bin/bash
cd /var/www/html
php artisan storage:link > /dev/null 2>&1
php artisan migrate --force
php artisan optimize > /dev/null 2>&1
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
