---
published: true
title: Introduction to OpenShift Service Mesh
tags:
  - openshift
  - redhat
  - service-mesh
  - istio
  - liberty
  - open-liberty
---
# Overview
OpenShift Service Mesh (OSSM) is the Red Hat version of the opensource [Istio](https://istio.io/) project, which provides seamless networking capabilities like dynamic endpoint routing, security, and health monitoring. 

I've also been told that OSSM is actually based on [Maistra](https://maistra.io/), rather than directly on Istio, and some of the setup steps are definitely `maistra.io` annotations.

Also, the [Kiali](https://kiali.io/) tool provides visualization of this networking configuration.

# Implementation

## Service Mesh Operator

The [Red Hat OpenShift Service Mesh Operator](https://catalog.redhat.com/software/container-stacks/detail/5ec53e8c110f56bd24f2ddc4) seems to be based on earlier versions of Maistra and Istio. That is, this official Operator seems to not stay on the leading edge of those upstream projects. Of particular note, I _think_ it's still using the 1.x Maistra project, not the newer 2.x.

Note this Operator also requires installation of the following Operators:
- ElasticSearch
- Jaeger
- Kiali

The Operator is globally installed in the OCP cluster. A "Control Plane" instance is then created, say in the `istio-system` Project. Then, a "Member Roll" is created, where Projects that want to participate in the Service Mesh must be manually added.

*Note that once a Project is added to the mesh (via the Member Roll), at least all external network routing (`Route` objects) to applications within that Project will cease to work until appropriate Istio objects are created for them.*

Documentation seems to suggest a simple label that will expose even non-managed applications, but I never got this to work.

## Application Enablement

To enable an Application to be managed by Istio/Service Mesh, the following steps are required:
1. Create a normal k8s `Service` object
1. Add an `annotation` for Istio Envoy sidecar injection to the application Pod template (e.g. in a `Deployment`)
1. Create an Istio [`VirtualService`](https://istio.io/latest/docs/reference/config/networking/virtual-service/) object to route to the above `Service`
1. Create an Istio "ingress" [`Gateway`](https://istio.io/latest/docs/reference/config/networking/gateway/) object to route to the above `VirtualService`

### Deployment example
```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: my-app1

spec:
  selector:
    matchLabels:
      app: my-app1

  template:
    metadata:
      labels:
        app: my-app1
      annotations:
        # for Service Mesh/Istio Envoy injection
        sidecar.istio.io/inject: 'true'
  ...
```

### OpenLiberty Operator example
```yaml
apiVersion: openliberty.io/v1beta1
kind: OpenLibertyApplication
metadata:
  name: my-api
  labels:
    app: my-api
  annotations:
    # for Service Mesh/Istio injection
    sidecar.istio.io/inject: 'true'
...
spec:
  ...
  expose: false   # will have istio expose instead
  ...
```
### VirtualService and Gateway example
The following can be split into separate files, but as you seem to always need both, I'm not sure what value that would provide.
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: my-api-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - my-api.apps.ocp1.myocp.com
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: my-api
spec:
  hosts:
  - my-api.apps.ocp1.myocp.com
  gateways:
  - my-api-gateway
  http:
  - route:
    - destination:
        host: my-api # reference to the Service
        port:
          number: 9080
```
I also really, really wish you didn't have to specify the full cluster host name in here. Most examples use `"*"` instead, but this won't work when you have more than one application from the Project participating. And the short name doesn't work either. (About which I've seen at least a couple of Issues raised somewhere.)

### Routes
Note that the Gateway creation, I _think_ specifically with `spec.selector.istio=ingressgateway`, actually causes a `Route` to be created over in the `istio-system` Project. This is why no `Route` in the application Project is needed/used.

```console
$ oc get routes -n istio-system
NAME                                                HOST/PORT                                                     PATH   SERVICES               PORT    TERMINATION          WILDCARD
my-project-my-api-gateway-3552b80c74b8b4d5          my-api.apps.ocp1.myocp.com
               istio-ingressgateway   http2                        None
my-project-my-app1-gateway-b9422a85a9e29f30         my-app1.apps.ocp1.myocp.com
               istio-ingressgateway   http2                        None
...
```

I believe this is due to [what Maistra calls IOR](https://github.com/maistra/ior), which does seem to be enabled by the OSSM Control Plane, by default.
```yaml
        istio-ingressgateway:
          autoscaleEnabled: false
          enabled: true
          gatewayType: ingress
          ior_enabled: true
          name: istio-ingressgateway
          resources:
            requests:
              cpu: 10m
              memory: 128Mi
          type: ClusterIP
```

I believe there are other approaches here that require more manual configuration, but I haven't understood those yet.

## External services
Istio can manage and visualize connections to external services as well, if those are wrapped in a [`ServiceEntry`](https://istio.io/latest/docs/reference/config/networking/service-entry/) object.

For example, to a JDBC Driver:
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: db2jdbc-svc-entry
spec:
  hosts:
  - db2server.mydomain.com
  ports:
  - number: 60000
    name: tcp
    protocol: tcp
  location: MESH_EXTERNAL
  resolution: DNS
```

# Troubleshooting
[Istio GitHub Troubleshooting article](https://github.com/istio/istio/wiki/Troubleshooting-Istio)

The [istioctl command-line tool](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/) can provide some insight into the current Istio configuration. It's apparently not supported by Red Hat, but it did work for me against our cluster. See [Debugging Envoy and Istiod](https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/).

Also, the Kiali tool does some configuration analysis and flags errors or warnings in the Istio configuration. Some of the things it warns about appear to be "best practice" items for Kiali itself, that don't break Istio functionality. But others are genuine mistakes in the configuration.

# References
- [Red Hat OpenShift Service Mesh 2.x](https://docs.openshift.com/container-platform/4.7/service_mesh/v2x/servicemesh-release-notes.html)
- [Deploying applications on Red Hat OpenShift Service Mesh](https://docs.openshift.com/container-platform/4.7/service_mesh/v2x/prepare-to-deploy-applications-ossm.html)
- [How to add an application to a Red Hat OpenShift Service Mesh](https://labs.consol.de/development/2020/08/07/adding-application-to-rhsm.html) - pretty useful overview of the whole process
- Official [Istio documentation](https://istio.io/latest/docs/reference/)
