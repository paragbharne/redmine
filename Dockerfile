FROM ubuntu:14.04
MAINTAINER Parag Bharne <pari.bharne@gmail.com>

##Installing dependencies ###

RUN apt-get update && sudo apt-get upgrade -y
RUN apt-get install -y apache2
RUN apt-get install -y apache2 php5 libapache2-mod-php5
RUN apt-get install -y libaprutil1-dev libmysqlclient-dev libmagickcore-dev libmagickwand-dev curl git-core gitolite patch build-essential 		bison zlib1g-dev libssl-dev libxml2-dev libxml2-dev sqlite3 libsqlite3-dev autotools-dev libxslt1-dev libyaml-0-2 autoconf automake 		libreadline6-dev libyaml-dev libtool imagemagick apache2-utils ssh zip libicu-dev libssh2-1 libssh2-1-dev cmake libgpg-error-dev 		subversion libapache2-svn
RUN a2enmod ssl
ADD apache.key /etc/apache2/ssl
ADD apache.crt /etc/apache2/ssl

ADD default-ssl.conf /etc/apache2/sites-available/
RUN a2ensite 000-default.conf
RUN a2ensite default-ssl

## Configure Subversion ##

RUN mkdir -p /var/lib/svn
RUN chown -R www-data:www-data /var/lib/svn
RUN a2enmod dav_svn
ADD dav_svn.conf /etc/apache2/mods-enabled/

#RUN a2enmod authz_svn

RUN htpasswd -c /etc/apache2/dav_svn.passwd redmine1

RUN svnadmin create --fs-type fsfs /var/lib/svn/myrepository1
RUN chown -R www-data:www-data /var/lib/svn
ADD dav_svn.authz /etc/apache2/

### Installing Ruby and Ruby on Rails ###

RUN apt-get install -y  ruby1.9.3 ruby1.9.1-dev ri1.9.1 libruby1.9.1 libssl-dev zlib1g-dev
RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
         --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                        /usr/share/man/man1/ruby1.9.1.1.gz \
        --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1

RUN gem update
RUN gem install bundler

###Installing of Redmine###
###Redmine###

RUN cd /usr/share
RUN wget http://www.redmine.org/releases/redmine-2.5.2.tar.gz
RUN tar xvfz redmine-2.5.2.tar.gz
RUN rm redmine-2.5.2.tar.gz
RUN mv redmine-2.5.2 redmine
RUN cp -r redmine /usr/share/
RUN chown -R root:root /usr/share/redmine
RUN chown www-data /usr/share/redmine/config/environment.rb
RUN ln -s /usr/share/redmine/public /var/www/html/redmine

##MySQL##

WORKDIR /usr/share/redmine/
ADD database.yml /usr/share/redmine/config/

##Configuration##

WORKDIR /usr/share/redmine/
RUN gem install mime-types -v 2.6.2
#RUN gem install mime-types-data -v '3.2016.0521'
#RUN cd /usr/share/redmine/
#RUN gem update
#RUN gem install bundler
RUN bundle install --without development test postgresql sqlite
RUN rake generate_secret_token
RUN RAILS_ENV=production rake db:migrate 
#RUN RAILS_ENV=production rake redmine:load_default_data
RUN mkdir public/plugin_assets
RUN chown -R www-data:www-data files log tmp public/plugin_assets
RUN chmod -R 755 files log tmp public/plugin_assets


##Installing Phusion Passenger##

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN apt-get -y  install apt-transport-https ca-certificates

ADD passenger.list /etc/apt/sources.list.d/

RUN chown root: /etc/apt/sources.list.d/passenger.list
RUN chmod 600 /etc/apt/sources.list.d/passenger.list

RUN apt-get update
RUN apt-get install -y  libapache2-mod-passenger

ADD 000-default.conf /etc/apache2/sites-available/
RUN a2ensite 000-default.conf
ADD configuration.yml /usr/share/redmine/config/

RUN a2enmod passenger

RUN a2ensite 000-default.conf
RUN a2ensite default-ssl


EXPOSE 80
EXPOSE 443
ENTRYPOINT service apache2 restart && bash
