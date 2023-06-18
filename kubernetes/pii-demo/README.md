[[Back to Index Page](../README.md)]

# PII Demo Application (Simple Database App)

The `pii-demo` application is a simple Apache/PHP/MySQL application that allows users to enter personally identifiable information (pii) and store it in a database. The application uses two containers: httpd and MySQL.

This folder contains yaml code required to deploy the application.

## Istio Configuration

The block diagram showing Istio flow when a blue application request is made can be seen below.

![pii-demo application block diagram](../images/pii-demo-istio-block-diagram-single.png)

We use a **Gateway** to describe a load balancer, operating at the edge of the mesh, that receives incoming HTTP connections. The specification describes a set of ports that should be exposed and the type of protocol to use, in our case **80** and **HTTP**, respectively. A VirtualService can then be bound to a gateway to control the forwarding of traffic arriving at a particular host.

We use a **VirtualService** to define a set of traffic routing rules to apply when a host is addressed, in our case **pii-demo.apps.hl.test**. A routing rule defines matching criteria for traffic of a specific protocol (TCP, TLS or http), in our case **http**. If the traffic is matched, then it is sent to a named destination service (or version of it) defined in the registry, in our case **httpd-server**.