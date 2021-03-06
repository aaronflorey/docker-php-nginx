#!/bin/bash
cd /var/www/html
php artisan storage:link > /dev/null 2>&1

if [ "$migrate" -eq "1" ]; then
    php artisan migrate --force > /dev/null 2>&1
fi

# if [ -z "$(php artisan optimize 2>&1 >/dev/null)" ]; then
#     echo "php artisan optimize failed, please check your code"
# fi

# if we have an env called cron that equals 1, add it to the cronjob
if [ "$cron" -eq "1" ]; then
   cp /etc/supervisor/extras/cron.conf /etc/supervisor/conf.d/cron.conf
fi

if [ "$queue" -eq "1" ]; then
    cp /etc/supervisor/extras/queue.conf /etc/supervisor/conf.d/queue.conf
fi

if [ "$horizon" -eq "1" ]; then
    cp /etc/supervisor/extras/horizon.conf /etc/supervisor/conf.d/horizon.conf
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf