#!/bin/bash
python3 manage.py collectstatic --clear --noinput # clearstatic files
python3 manage.py collectstatic --noinput  # collect static files

python3 manage.py create_superuser_from_secrets

echo Running make migrations
python3 manage.py makemigrations
echo Running migrate
python3 manage.py migrate

# Prepare log files and start outputting logs to stdout
rm -rf /app/logs
mkdir /app/logs
touch /app/logs/gunicorn.log
touch /app/logs/access.log
tail -n 0 -f /app/logs/*.log &
echo Starting nginx 
# Start Gunicorn processes
echo Starting Gunicorn.
exec gunicorn mwilliamson_portfolio_python.wsgi:application \
    --name mwilliamson_portfolio_python \
    --bind unix:mwilliamson_portfolio_python.sock \
    --workers 3 \
    --log-level=info \
    --log-file=/app/logs/gunicorn.log \
    --access-logfile=/app/logs/access.log & 
exec service nginx start
