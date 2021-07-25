FROM centos:7
RUN yum install -y java
ADD apache-tomcat-9.0.45.tar.gz /opt/
CMD [ "/opt/apache-tomcat-9.0.45/bin/catalina.sh", "run" ]
