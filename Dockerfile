FROM ubuntu:14.04

MAINTAINER paragbharne


run apt-get update
run apt-get upgrade -y


run apt-get -y install apache2 php5 libapache2-mod-php5 mysql-server php5-mysql libapache2-mod-perl2 libcurl4-openssl-dev libssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev libmysqlclient-dev libmagickcore-dev libmagickwand-dev curl git-core gitolite patch build-essential bison zlib1g-dev libssl-dev libxml2-dev libxml2-dev sqlite3 libsqlite3-dev autotools-dev libxslt1-dev libyaml-0-2 autoconf automake libreadline6-dev libyaml-dev libtool imagemagick apache2-utils ssh zip libicu-dev libssh2-1 libssh2-1-dev cmake libgpg-error-dev subversion libapache2-svn
run apt-get -y install subversion libapache2-svn
run apt-get -y  install git
run mkdir -p /var/lib/svn
run chown -R www-data:www-data /var/lib/svn


run a2enmod dav_svn


run rm -f /etc/apache2/mods-enabled/dav_svn.conf

workdir /tmp
run git clone https://github.com/pratheeshts0/redmine.git

workdir /tmp/redmine/


run cp dav_svn.conf /etc/apache2/mods-enabled/

#run  a2enmod authz_svn

run cp dav_svn.passwd /etc/apache2/
run svnadmin create --fs-type fsfs /var/lib/svn/my_repository
run chown -R www-data:www-data /var/lib/svn
run cp dav_svn.authz /etc/apache2/



#Installing Ruby and Ruby on Rails


run apt-get -y install  software-properties-common

run add-apt-repository ppa:brightbox/ruby-ng
run apt-get update
run apt-get -y install ruby2.1 ruby-switch ruby2.1-dev ri2.1 libruby2.1 libssl-dev zlib1g-dev
run ruby-switch --set ruby2.1
run gpg --keyserver hkp://pgp.mit.edu --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
run curl -sSL https://get.rvm.io | bash -s stable

run apt-get -y install ruby1.9.3 ruby1.9.1-dev ri1.9.1 libruby1.9.1 libssl-dev zlib1g-dev
run update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby1.9.1.1.gz --slave   /usr/bin/ri ri /usr/bin/ri1.9.1  --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1

run gem update
run gem install bundler

workdir /usr/share
run wget http://www.redmine.org/releases/redmine-3.0.4.tar.gz
run tar xvfz redmine-3.0.4.tar.gz
run rm redmine-3.0.4.tar.gz
run mv redmine-3.0.4 redmine
run chown -R root:root /usr/share/redmine
run  chown -R www-data:www-data /usr/share/redmine

run chown www-data /usr/share/redmine/config/environment.rb
run ln -s /usr/share/redmine/public /var/www/html/redmine

workdir /tmp/redmine
run cp database.yml /usr/share/redmine/config/

workdir /usr/share/redmine/
run gem install mime-types-data -v '3.2016.0521'
run bundle install --without development test postgresql sqlite

run rake generate_secret_token
run rake db:migrate RAILS_ENV=production
#run rake db:migrate RAILS_ENV=production
#run RAILS_ENV=production rake db:migrate
run RAILS_ENV=production REDMINE_LANG=fr bundle exec rake redmine:load_default_data
#run RAILS_ENV=production rake redmine:load_default_data
#run mkdir public/plugin_assets
run chown -R www-data:www-data files log tmp public/plugin_assets
run chmod -R 755 files log tmp public/plugin_assets
run apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
run apt-get -y install apt-transport-https ca-certificates

workdir /tmp/redmine
run cp passenger.list /etc/apt/sources.list.d/
run chown www-data:www-data /etc/apt/sources.list.d/passenger.list

run chown root: /etc/apt/sources.list.d/passenger.list
run chmod 777 /etc/apt/sources.list.d/passenger.list


run apt-get update
run apt-get -y install libapache2-mod-passenger
run rm -f /etc/apache2/mods-available/passenger.conf

workdir /tmp/redmine

run cp passenger.conf /etc/apache2/mods-available/
run cp default.conf /etc/apache2/sites-available/
run a2enmod passenger
run a2ensite default.conf
run a2dissite 000-default.conf

run  mkdir /etc/apache2/ssl
workdir /tmp/redmine
run cp server.key /etc/apache2/ssl
run cp server.crt /etc/apache2/ssl
run a2enmod ssl
workdir /tmp/redmine
run cp ssl.conf /etc/apache2/sites-available/
run a2ensite ssl.conf
run a2dissite default-ssl.conf

workdir /opt
run git clone https://github.com/pratheeshts0/redmine.git
run cp /opt/redmine/configuration.yml /usr/share/redmine/config/









#workdir /usr
#run git clone https://github.com/pratheeshts0/redmine.git
#run cp /usr/redmine/plugins/*.bz2 /usr/share/redmine/plugins/

#run tar xfj /usr/share/redmine/plugins/*.bz2 -C /usr/share/redmine/plugins/ || pwd

#workdir /usr/share/redmine/
#run chown -R www-data:www-data plugins/
#run rake generate_secret_token
#run rake redmine:plugins:migrate RAILS_ENV=production

EXPOSE 80
EXPOSE 443
entrypoint service apache2 restart && bash
