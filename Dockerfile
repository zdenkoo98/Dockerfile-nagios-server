FROM centos

RUN yum -y install httpd php gcc glibc glibc-common wget perl gd gd-devel unzip zip make
RUN useradd nagios
RUN groupadd nagcmd
RUN usermod -a -G nagcmd nagios
RUN usermod -a -G nagcmd apache 
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.4.tar.gz
RUN tar -zxvf nagios-4.*.tar.gz
RUN ls 
WORKDIR nagios-4.3.4
RUN ./configure --with-nagios-group=nagios --with-command-group=nagcmd
RUN make all
RUN make install
RUN make install-init
RUN make install-config
RUN make install-commandmode
RUN make install-webconf
RUN make install-exfoliation
RUN wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz 
RUN tar -zxvf nagios-plugins-2.*.tar.gz
WORKDIR nagios-plugins-2.2.1
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios
RUN make
RUN make install 
RUN /sbin/apachectl -D BACKGROUND
RUN /etc/rc.d/init.d/nagios start
RUN touch /var/www/html/index.html
RUN chmod 755 /var/www/html/index.html

EXPOSE 22 

ENTRYPOINT ["/usr/bin/bash"]


