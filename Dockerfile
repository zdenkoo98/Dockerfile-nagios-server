#Image
FROM centos
#Installation of packages 
RUN yum -y install httpd php gcc glibc glibc-common wget perl gd gd-devel unzip zip make openssh-server
#SSH
RUN mkdir /var/run/sshd
RUN echo 'root:rootpasswd' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 
RUN echo "export VISIBLE=now" >> /etc/profile
#Esto no funca, correrlo despues de correr el container y despues resetear nagios
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
#NRPE installation
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install nagios-plugins-nrpe
#Nagios-remote-host configuration
WORKDIR /usr/local/nagios/etc
RUN sed -i 's+#cfg_dir=/usr/local/nagios/etc/servers+cfg_dir=/usr/local/nagios/etc/servers+g' nagios.cfg
RUN mkdir /usr/local/nagios/etc/servers 
#Check_NRPE command config
WORKDIR /usr/local/nagios/etc/objects
RUN echo 'define command{' >> commands.cfg
RUN echo 'command_name check_nrpe' >> commands.cfg
RUN echo 'command_line /usr/lib64/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -t 30 -c $ARG1$' >> commands.cfg
RUN echo '}' >> commands.cfg
#Run apache and nagios services
RUN /sbin/apachectl -D BACKGROUND
RUN /etc/rc.d/init.d/nagios start
#Apache index creation
RUN touch /var/www/html/index.html
RUN chmod 755 /var/www/html/index.html
#Ports to expose (ssh, http and NRPE)
EXPOSE 22 80 5666 25
COPY nagios-client.cfg /usr/local/nagios/etc/servers/



ENTRYPOINT ["/usr/bin/bash"]


