#!/bin/bash
cd /var/www/html
php artisan storage:link 2&1> /dev/null
#php artisan migrate --force
php artisan optimize 2&1> /dev/null
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf