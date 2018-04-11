#!/bin/bash
# Upgrade Ubuntu noninteractive
unset UCF_FORCE_CONFFOLD
export UCF_FORCE_CONFFNEW=YES
ucf --purge /boot/grub/menu.lst
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy upgrade
apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade
apt-get autoremove -y
apt-get autoclean -y

# Install git
apt-get install git htop apache2 -y
apt-get remove --purge snapd -y 

############################################################################
# This sets up Let's Encrypt SSL certificates and automatic renewal 
# using certbot: https://certbot.eff.org
#
# - Run this script as root.
# - A webserver must be up and running.
#
# Certificate files are placed into subdirectories under
# /etc/letsencrypt/live/*.
# 
# Configuration must then be updated for the systems using the 
# certificates.
#
# The certbot-auto program logs to /var/log/letsencrypt.
############################################################################
 
set -o nounset
set -o errexit
 
# May or may not have HOME set, and this drops stuff into ~/.local.
export HOME="/root"
export PATH="$${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
# No package install yet.
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
mv certbot-auto /usr/local/bin
 
# Install the dependencies.
certbot-auto --noninteractive --os-packages-only
 
# Set up config file.
mkdir -p /etc/letsencrypt
cat > /etc/letsencrypt/cli.ini <<EOF
# Uncomment to use the staging/testing server - avoids rate limiting.
# server = https://acme-staging.api.letsencrypt.org/directory
 
# Use a 4096 bit RSA key instead of 2048.
rsa-key-size = 4096
 
# Set email and domains.
email = user@yourdomain
domains = yourdomain.com
 
# Text interface.
text = True
# No prompts.
non-interactive = True
# Suppress the Terms of Service agreement interaction.
agree-tos = True
 
# Use the webroot authenticator.
authenticator = webroot
webroot-path = /var/www/html
EOF
 
# Obtain cert.
certbot-auto certonly
 
# Set up daily cron job.
CRON_SCRIPT="/etc/cron.daily/certbot-renew"
 
cat > "$${CRON_SCRIPT}" <<EOF
#!/bin/bash
#
# Renew the Let's Encrypt certificate if it is time. It won't do anything if
# not.
#
# This reads the standard /etc/letsencrypt/cli.ini.
#
 
# May or may not have HOME set, and this drops stuff into ~/.local.
export HOME="/root"
# PATH is never what you want it it to be in cron.
export PATH="\$${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
certbot-auto --no-self-upgrade certonly
 
# If the cert updated, we need to update the services using it. E.g.:
if service --status-all | grep -Fq 'apache2'; then
  service apache2 reload
fi
if service --status-all | grep -Fq 'httpd'; then
  service httpd reload
fi
if service --status-all | grep -Fq 'nginx'; then
  service nginx reload
fi
EOF
chmod a+x "$${CRON_SCRIPT}"


# Remove index apache
rm -rf /var/www/html/index.html

# Empty File
echo -n > /etc/apache2/sites-enabled/000-default.conf

# Change VirtualHost Configuration Apache
cat > "/etc/apache2/sites-enabled/000-default.conf" <<EOF
<VirtualHost *:80>

ServerAdmin devops@yourdomain
ServerName yourdomain
Redirect / https://yourdomain

</VirtualHost>


<VirtualHost *:443>

ServerName yourdomain
DocumentRoot /var/www/html
SSLEngine On
SSLCertificateFile /etc/letsencrypt/live/yourdomain/cert.pem
SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain/privkey.pem
SSLCertificateChainFile /etc/letsencrypt/live/yourdomain/chain.pem

</VirtualHost>
EOF

# GitHub Game to /var/www/html/
git clone https://github.com/platzhersh/pacman-canvas.git /var/www/html/

# Apache Configuration
a2enmod ssl
systemctl restart apache2.service
