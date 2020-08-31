#!/bin/bash
cd /var/www/html
#php artisan storage:link > /dev/null 2>&1
php artisan migrate --force > /dev/null 2>&1

if [ -z "$(php artisan optimize 2>&1 >/dev/null)" ]; then
    echo "php artisan optimize failed, please check your code"
fi

# if we have an env called cron that equals 1, add it to the cronjob
if [ "$cron" -eq "1" ]; then
   echo "*       *       *       *       *       php /var/www/html/artisan schedule:run" > /var/spool/cron/crontabs/root
fi

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
