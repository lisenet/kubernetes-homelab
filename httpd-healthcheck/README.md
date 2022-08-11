# What is httpd-healthcheck?

It is a simple httpd healthcheck that I use with Istio ingressgateway load balancer.

Apache is configured to bind to port 10001.

## How to use this image?

This image only contains Apache httpd with the defaults from upstream. There is no PHP installed.
```
docker run -d -p 8080:10001 lisenet/httpd-healthcheck:1.0.0
```

Visit http://localhost:8080 and you will see "httpd-healthcheck".
