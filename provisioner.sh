#!/bin/bash

# Install system dependencies.
sudo apt-get update && sudo apt-get --yes install git libapache2-mod-wsgi

# Clone specific branch from remote repository.
git clone --single-branch -b "${branch}" "https://${github_user}:${github_token}@github.com/${github_organization}/${project_name}.git"

# Save some variables locally.
echo '{"DB_HOST": "bar"}' > $HOME/vars.json

# Install Python dependencies
pip3 install requirements -r $HOME/"${project_name}/requirements.txt"

# Write mod_wsgi file for Flask.
echo "
import sys
sys.path.insert(0, '${path_to_application}')
from autoscale import app as application
" > "${path_to_application}/${project_name}"

# Write Apache configuration file.
echo "
<VirtualHost *:80>
   # ServerName "${dns}"
   # Redirect / https://"${dns}"
</VirtualHost>

<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    ServerAdmin webmaster@localhost
    # ServerName "${dns}"
    WSGIDaemonProcess "${project_name}" user=ubuntu group=ubuntu threads=5
    WSGIScriptAlias / /home/ubuntu/app/${project_name}/app.wsgi
    <Directory /home/ubuntu/app/${project_name}/>
      WSGIProcessGroup ${project_name}
      WSGIApplicationGroup %{GLOBAL}
      WSGIScriptReloading On
      Require all granted
    </Directory>
  </VirtualHost>
</IfModule>
" > /etc/apache2/sites-available/flask.conf

# Disable default Apache configuration.
sudo a2dissite 000-default

# Enable new Apache configuration.
sudo a2ensite "${project_name}.conf"
