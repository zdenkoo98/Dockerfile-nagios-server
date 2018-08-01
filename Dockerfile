#Which base image to use
FROM centos
#Installation of packages 
RUN yum -y install httpd php gcc glibc glibc-common wget perl gd gd-devel unzip zip make openssh-server
#SSH
RUN mkdir /var/run/sshd
RUN echo 'root:rootpasswd' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
RUN echo "export VISIBLE=now" >> /etc/profile
RUN /usr/bin/ssh-keygen -A
RUN /usr/sbin/sshd
#Users and groups configuration
RUN useradd nagios
RUN groupadd nagcmd
RUN usermod -a -G nagcmd nagios
RUN usermod -a -G nagcmd apache 
#Nagios installation
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
#Nagios plugins installation
RUN wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz 
RUN tar -zxvf nagios-plugins-2.*.tar.gz
WORKDIR nagios-plugins-2.2.1
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios
RUN make
RUN make install 
#Run apache and nagios services
RUN /sbin/apachectl -D BACKGROUND
RUN /etc/rc.d/init.d/nagios start
#Apache index creation
RUN touch /var/www/html/index.html
RUN chmod 755 /var/www/html/index.html
#Ports to expose (ssh and http)
EXPOSE 22 80

ENTRYPOINT ["/usr/bin/bash"]


