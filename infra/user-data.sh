#!/bin/bash
sudo yum --assumeyes update
sudo yum --assumeyes install httpd git
mkdir /var/www/vhosts
cd /tmp
git clone https://github.com/jeromedecoster/aws-gitops-terraform.git --depth 1
mv aws-gitops-terraform/www /var/www/vhosts/example.com

cat <<EOF > /etc/httpd/conf.d/vhost.conf
<VirtualHost *:80>
    # REQUIRED. Set this to the host/domain/subdomain that
    # you want this VirtualHost record to handle.
    ServerName example.com

    # Optional. You can specify additional host names that
    # serve up the same site. This can be top-level, domains,
    # sub-domains, and can even use wildcard subdomains such
    # as *.example.com - just separate each host name
    # with a single space.
    #ServerAlias www.example.com example.net

    # REQUIRED. Set this to the directory you want to use for
    # this vhost site's files.
    DocumentRoot /var/www/vhosts/example.com

    # Optional. Uncomment this and set it to your admin email
    # address, if you have one. If there is a server error,
    # this is the address that Apache will show to users.
    #ServerAdmin you@example.com

    # Optional. Uncomment this if you want to specify
    # a different error log file than the default. You will
    # need to create the error file first.
    #ErrorLog /var/www/vhosts/logs/error_log

    # REQUIRED. Let's make sure that .htaccess files work on
    # this site. Don't forget to change the file path to
    # match your DocumentRoot setting above.
    <Directory /var/www/vhosts/example.com>
        AllowOverride All
    </Directory>
</VirtualHost>
EOF

sudo systemctl enable httpd
sudo systemctl start httpd