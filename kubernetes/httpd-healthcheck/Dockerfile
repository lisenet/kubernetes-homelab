FROM httpd:2.4
RUN sed -i 's/80/10001/g' /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/original/httpd.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
RUN echo "httpd-healthcheck" > /usr/local/apache2/htdocs/index.html
