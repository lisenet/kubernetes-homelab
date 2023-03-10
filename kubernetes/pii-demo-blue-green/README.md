[[Back to Index Page](../README.md)]

# PII Demo Application (Simple Database App)

The `pii-demo` application is a simple Apache/PHP/MySQL application that allows users to enter personally identifiable information (pii) and store it in a database. The application uses two containers: httpd and MySQL.

This folder contains yaml code for the blue/green deployment of the application.

## Blue/Green Deployment

Blue/green deployment is an application release model that transfers user traffic from a previous version of a microservice to a new release, both of which are running in production, without downtime. 

The block diagram showing Istio flow when a blue application request is made can be seen below.

![pii-demo application block diagram](../images/pii-demo-istio-block-diagram-blue-green.png)

When a user makes a request to **pii-demo-blue.apps.hl.test**, only blue versions of pods are used.

![pii-demo blue](../images/pii-demo-blue.png)

When a request is made to **pii-demo-green.apps.hl.test**, only green versions of pods are used.

![pii-demo green](../images/pii-demo-green.png)

If a user were to make a request to **pii-demo.apps.hl.test**, it would be routed to either blue or green version using round robin because of our configuration. This behaviour can be changed by managing routing at the DNS level, for example, **pii-demo.apps.hl.test** could be a CNAME/alias pointing to **pii-demo-blue.apps.hl.test** before the deployment of the green version, and changed to point to **pii-demo-green.apps.hl.test** after the green version has been deployed.

## Kiali Graphs

See the Istio workload graph for blue/green deployment below. The padlock indicates that connections are mTLS encrypted. 

![pii-demo istio workload graph](../images/pii-demo-istio-workload-graph-kiali.png)

See the versioned application graph below.

![pii-demo istio versioned app graph](../images/pii-demo-istio-versioned-app-graph-kiali.png)