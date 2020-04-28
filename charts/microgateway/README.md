# Airlock microgateway
============

Airlock Microgateway, a WAF container solution to protect other services.

The current chart version is: 0.4.1

## Table of contents
* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Quick start guide](#quick-start-guide)
  * [Adding the chart repository](#adding-the-chart-repository)
  * [Installing the chart](#installing-the-chart)
  * [Uninstalling the chart](#uninstalling-the-chart)
* [Configuration](#configuration)
* [Dependencies](#dependencies)
* [DSL Configuration](#dsl-configuration)
  * [Simple DSL configuration](#simple-dsl-configuration)
  * [Advanced DSL app configuration](#advanced-dsl-app-configuration)
  * [Expert DSL configuration](#expert-dsl-configuration)

## Introduction
This Helm chart bootstraps [Airlock Microgateway](https://www.airlock.com) on a [Kubernetes](https://kubernetes.io) or [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh) package manager. It provisions an Airlock Microgateway pod with a default configuration which can be adjusted to customer needs. For more details about the configuration options, see chapter [Helm basics](#helm-basics).

## Prerequisites
* The Airlock Microgateway image
* A valid license for Airlock Microgateway
* Redis service for sessionhandling (see chapter [Dependencies](#dependencies))

## Quick start guide

The following subchapters describe how to use the Helm chart.

### Adding the chart repository

To add the chart repository:

```console
helm repo add airlock https://ergon.github.io/airlock-helm-charts/
```

### Installing the chart

To install the chart with the release name `microgateway`:

```console
helm upgrade -i microgateway airlock/microgateway
```

### Uninstalling the chart

To uninstall the chart with the release name `microgateway`:

```console
helm uninstall microgateway
```

## Configuration

The following table lists configuration parameters of the Airlock Microgateway chart and the default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | string | `nil` | Assign custom [affinity rules](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) (multiline string) |
| commonLabels | object | `{}` | Labels to apply to all resources |
| config.IPHeader.header | string | `"X-Forwarded-For"` | HTTP header to extract the client IP address. |
| config.IPHeader.trustedProxies | list | `[]` | Trusted IP addresses to extract the client IP from HTTP header.<br> :exclamation: IP addresses are only extracted if `trustedProxies` are configured. |
| config.apps | list | `[]` | See [Advanced DSL app configuration](#advanced-dsl-app-configuration) |
| config.default | object | See `config.default.*` parameters | See [Simple DSL configuration](#simple-dsl-configuration) |
| config.default.backend.hostname | string | `"backend-service"` | Backend Hostname |
| config.default.backend.port | int | `8080` | Backend Port |
| config.default.backend.protocol | string | `"http"` | Backend Protocol |
| config.default.backend.tls.cipherSuite | string | `""` | Set the back-end SSL cipher list (up to TLS 1.2). For documentation visit [openssl.org](www.openssl.org) and search for "ciphers" |
| config.default.backend.tls.cipherSuitev13 | string | `""` | Set the back-end SSL cipher list (TLS 1.3). For documentation visit [openssl.org](www.openssl.org) and search for "ciphers" |
| config.default.backend.tls.clientCert | bool | `false` | Backend TLS clientCert ('true', 'false'). Uses the Certificate from 'config.tlsSecretName' |
| config.default.backend.tls.serverCa | bool | `false` | Backend TLS serverCa ('true', 'false'). Uses the Certificate from 'config.tlsSecretName' |
| config.default.backend.tls.verifyHost | bool | `false` | Backend TLS certificate verifyHost ('true', 'false') |
| config.default.backend.tls.version | string | `""` | Backend TLS Version. Set the back-end SSL protocol version: (`Default`, `SSLv3`, `TLSv1.0`, `TLSv1.1`, `TLSv1.2`, `TLSv1.3`, `TLSv1.x`). Note: TLSv1 is a legacy value with the same meaning as TLSv1.0 |
| config.default.mapping.denyRules.enabled | bool | `true` | If deny rules should be enabled |
| config.default.mapping.denyRules.level | string | `"standard"` | Deny rule level (`basic`, `standard`, `strict`) |
| config.default.mapping.denyRules.logOnly | bool | `false` | Deny rule log only |
| config.default.mapping.entryPath | string | `"/"` | The `entry_path` for this app |
| config.default.mapping.operationalMode | string | `"production"` | Specifies the operational mode of this mapping (`production`, `integration`) |
| config.default.mapping.sessionHandling | string | `""` | Session handling for this app. If redis enabled this value is `enforce_session`, if redis disabled false this value is `ignore_session`. |
| config.default.virtualHost.tls.cipherSuite | string | `""` | Virtual Host TLS cipherSuite. `ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:AES256-SHA:AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA` |
| config.default.virtualHost.tls.protocol | string | `""` | Virtual Host TLS Protocol. (`all`, `SSLv3`, `TLSv1`, `TLSv1.1`, `TLSv1.2`) Versions can be excluded with -<Version_Name>. |
| config.dsl | object | `{}` | See [Expert DSL configuration](#expert-dsl-configuration) |
| config.env | list | `[]` | List of environment variables (YAML array) |
| config.existingSecret | string | `nil` | An existing secret to be used, must contain the keys `license` and `passphrase` |
| config.expert_settings.apache | string | `nil` | Global Apache Expert Settings (multiline string) |
| config.expert_settings.security_gate | string | `nil` | Global SecurityGate Expert Settings (multiline string) |
| config.license | string | `nil` | License for the Microgateway (multiline string) |
| config.logLevel | string | `"info"` | Log level (`info`, `trace`) |
| config.passphrase | string | `nil` | Encryption passphrase used for the session. A random one is generated on each upgrade if not specified here or in `config.existingSecret` |
| config.redisService | list | `[]` | List of Redis service hostname. If `redis.enabled true`, `redis-master` is set as hostname by default. |
| config.tlsSecretName | string | `nil` | Name of an existing secret containing the TLS Secrets for the Microgateway. Virtual Host TLS needs the keys `tls.crt`, `tls.key` and `ca.crt`. Make sure to update `route.tls.destinationCACertificate` accordingly, if used. Backend TLS needs the keys `backend-client.crt`, `backend-client.key` and `backend-server-validation-ca.crt`. |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image.pullPolicy | string | `"Always"` | Pull policy (`Always`, `IfNotPresent`, `Never`) |
| image.repository | string | `"docker.ergon.ch/airlock/microgateway"` | Image repository |
| image.tag | string | `"7.4.sprint10_Build008"` | Image tag |
| imagePullSecrets | list | `[]` | Reference to one or more secrets to be used when pulling images |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/rewrite-target":"/"}` | Annotations to set on the ingress |
| ingress.enabled | bool | `false` | If an ingress should be created |
| ingress.hosts | list | `["chart-example.local"]` | List of host names |
| ingress.labels | object | `{}` | Labels to set on the ingress |
| ingress.path | string | `"/"` | Path the ingress serves |
| ingress.targetPort | string | `"http"` | Target port of the service (`http`, `https` or number) |
| ingress.tls | list | `[]` | [Ingress TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration (YAML array) |
| livenessProbe.enabled | bool | `true` | Enable liveness probes |
| livenessProbe.initialDelaySeconds | int | `90` | Initial delay in seconds |
| nameOverride | string | `""` | Provide a name in place of `microgateway` |
| nodeSelector | object | `{}` | Define which nodes the pods are scheduled on (YAML) |
| podSecurityContext | object | `{}` | Security context for the pods (see [link](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod)) |
| readinessProbe.enabled | bool | `true` | Enable readiness probes |
| readinessProbe.initialDelaySeconds | int | `30` | Initial delay in seconds |
| redis.cluster.enabled | bool | `true` |  |
| redis.enabled | bool | `false` | If true, the Redis chart will be installed. See [Redis chart](https://github.com/bitnami/charts/tree/master/bitnami/redis) for further documentation and available parameters |
| redis.fullnameOverride | string | `"redis"` |  |
| redis.image.repository | string | `"redis"` |  |
| redis.image.tag | string | `"5.0.8"` |  |
| redis.master.command | string | `"redis-server"` |  |
| redis.master.disableCommands[0] | string | `"FLUSHDB"` |  |
| redis.persistence.enabled | bool | `false` |  |
| redis.securityContext.fsGroup | int | `1000140000` |  |
| redis.securityContext.runAsUser | int | `1000140000` |  |
| redis.slave.command | string | `"redis-server"` |  |
| redis.usePassword | bool | `false` |  |
| replicaCount | int | `1` | Desired number of Microgateway pods |
| resources | object | `{"limits":{"cpu":"4","memory":"4048Mi"},"requests":{"cpu":"500m","memory":"512Mi"}}` | [Resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) for Microgateway |
| route.annotations | object | `{}` | Annotations to set on the route |
| route.enabled | bool | `false` | If a route should be created |
| route.hosts | list | `["chart-example.local"]` |  List of host names |
| route.labels | object | `{}` | Labels to set on the route |
| route.path | string | `"/"` | Path the route serves |
| route.targetPort | string | `"https"` | Target port of the service (`http`, `https` or number) |
| route.tls.certificate | string | `nil` | Certificate to be used (multiline string) |
| route.tls.destinationCACertificate | string | Microgateway default certificate | Backend CA to trust with termination `reencrypt` (multiline string) |
| route.tls.enabled | bool | `true` | Enable TLS for the route |
| route.tls.insecureEdgeTerminationPolicy | string | `"Redirect"` | Define the insecureEdgeTerminationPolicy of the route (`Allow`, `Redirect`, `None`) |
| route.tls.key | string | `nil` | Private key to be used for certificate (multiline string) |
| route.tls.termination | string | `"reencrypt"` | Termination of the route (`edge`, `reencrypt`, `passthrough`) |
| securityContext | object | `{}` | Security context for the microgateway container (see [link](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container)) |
| service.annotations | object | `{}` | Annotations to set on the service |
| service.labels | object | `{}` | Labels to set on the service |
| service.port | int | `80` | Service port |
| service.tlsPort | int | `443` | Service TLS port |
| service.type | string | `"ClusterIP"` | [Service type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) |
| tolerations | list | `[]` | Tolerations for use with node [taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) (YAML array) |

## Dependencies

The Airlock Microgateway Helm chart has the following optional dependencies which can be enabled for an easy start.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | redis | 10.6.0 |

### Redis

In case that sessionhandling is enabled on Airlock Microgateway, a Redis service needs to be available. The Airlock Microgateway Helm chart has two options:
* To deploy the dependend Redis service, adapt the Helm chart configuration as shown below:
  custom-values.yaml
  ```
  redis:
    enabled: true
  ```
* To use an existing Redis service, adapt the Helm chart configuration as shown below:
  custom-values.yaml
  ```
  config:
    redisService:
      - <REDIS-SERVICE1>:<PORT>
      - <REDIS-SERVICE2>:<PORT>
  ```


Finally, apply the adapted Helm chart configuration file with -f parameter.

```console
helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml
```

:information_source: **Possible settings**:
Please refer to the [Redis Helm chart](https://hub.helm.sh/charts/bitnami/redis) to see all possible parameters of the Redis Helm chart.

:warning: **Adjustments of the default settings**: 
Please note that the dependend Redis service has been tested with the settings this Helm chart is delivered. Changing those settings can cause issues.

### Echo-Server

For the first deployment it could be very useful to have a backend service proceeding the requests. For this purpose the dependend echo-server can be deployed by doing the following:
  custom-values.yaml
  ```
  echo-server:
    enabled: true
  ```
Finally, apply the adapted Helm chart configuration file with -f parameter.

```console
helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml
```

:information_source: **Possible settings**:
Please refer to the [Echo-Server Helm chart](https://ealenn.github.io/Echo-Server/pages/helm.html) to see all possible parameters of the Echo-Server Helm chart.

## Helm basics
In this chapter the Helm basics are described.
The Helm charts already offers default values, so that as little as possible needs to be adjusted to ensure a secure installation of the Microgateway. 
Depending on the environment and configuration, different values must be adjusted. There are various possibilities for that. 

* --values / -f  
  The -f parameter can be used to specify a custom-values.yaml file that overwrites the default values of the Chart during deployment.
  Such a file could look like the following. It is important that the indentation of the key value pairs is correct.
  custom-values.yaml
  ```
  config:
    default:
      backend:
        hostname: backend-hostname
    existingSecret: "microgatewaysecrets"
  imagePullSecrets:
    - name: "dockersecret"
  ingress:
    enabled: true
    hosts:
        - virtinc.com
  ```

## DSL Configuration
With the Helm chart you have three different possibilities to configure the DSL of the Microgateway. 
Depending on the environment and use-case, another option may be the best and easiest choice for the implementation. 

### Simple DSL configuration
The Helm chart provides a simple configuration which can be configured with `config.default.*` parameters.
All settings have already configured a default value. So only the values which differ from the default value have to be configured. 

Example code fragment:
Customization of the backend hostname.
custom-values.yaml
```
config:
  default:
    backend:
      hostname: custom-backend
```

### Advanced DSL app configuration
If the default app settings are not sufficient, you can define a custom app as YAML with the `config.apps` parameter. 
This setting overwrites the default app (mapping & backend), but the remaining settings of the DSL can still be configured with the default DSL method. 
Example code fragment:
Customization of the VirtualHost with Apache Expert Settings.
custom-values.yaml
```
config:
  expert_settings:
    apache: |
      LogLevel debug
  apps: | 
    - virtual_host:
        hostname: custom-hostname
      backend:
        hostname: backend-service
      mappings:
        - name: app
          entry_path: /
          backend_path: /app/
```

### Expert DSL configuration
In case that both other configuration options are not sufficient, create a custom config using `config.dsl`. All the configuration of the DSL can be used.
Overwrites all config defaults of this chart. 

## Security (TBD)

### Hardening (TBD)

### Deny Rule Handling (TBD)

### Secrets
Several different Secrets are required to configure the Microgateway properly.  
Some of these secrets can be generated during the installation of the chart, others must be created in advance and then referenced in the Microgateway chart.   
The following examples show how to create a secret and how to use it with the Microgateway.  

#### existingSecret
This secret contains the license and the passphrase (for encryption). 
For example, this secret can be created as follows:
```
kubectl create secret generic microgatewaysecrets --from-file=license=license_file --from-file=passphrase=passphrase_file
```
This secret can then be used with the following custom-values.yaml configuration:
```
config:
  existingSecret: "microgatewaysecrets"
```

#### imagePullSecrets
To download the Microgateway image from a private docker repository, an imagePullSecret is required.
For example, this secret can be created as follows:
```
kubectl create secret docker-registry dockersecret --docker-username=<Username> --docker-password=<Access_Token>
```
This secret can then be used with the following custom-values.yaml configuration:
```
imagePullSecrets: 
    - name: "dockersecret"
```

#### tlsSecretName 
The TLS certificates that are used by the Microgateway can be stored in a secret, so that only the secret name needs to be specified during deployment.  
Microgateway certificates include both Virtual Host TLS certificates and the TLS certificates for the backend if the backend is to be connected via TLS.  
Depending on the desired TLS configuration, other certificates are required in Secret.   
Virtual Host TLS needs the keys `tls.crt`, `tls.key` and `ca.crt`. Make sure to update `route.tls.destinationCACertificate` accordingly, if used.  
Backend TLS needs the keys `backend-client.crt`, `backend-client.key` and `backend-server-validation-ca.crt`.  

For example, this secret can be created as follows:
```
kubectl create secret generic microgatewaytls --from-file=tls.crt=virtinc-tls.crt --from-file=tls.key=virtinc-tls.key --from-file=ca.crt=virtinc-ca.crt
```
This secret can then be used with the following custom-values.yaml configuration:
```
config:
  tlsSecretName: "microgatewaytls"
```

## Examples
Here are some examples of how the Microgateway could be installed.   
Depending on the requirements and knowledge level, one or the other example may be more suitable for your environment.  

### DSL Configuration Examples
The chapter [DSL Configuration](#dsl-configuration) already described how to configure the DSL with the Helm chart.   
In the following chapters, various examples of these configuration options are given to help you better understand the DSL mechanism in order to use it as efficiently as possible.  
Depending on the requirements of the Microgateway configuration, a different DSL must be created.   

#### Simple setup example 
The Simple Setup assumes that it has a virtual host, mapping and backend each.   
For the Simple Setup all settings `config.*` are available.  
Thus, the user does not have to write and provide his own DSL. The generation of the DSL with the required values is done by the Helm chart.  

simple-values.yaml
```
config:
  default:
    mapping:
      operationalMode: integration
      denyRules:
        level: strict
    backend:
      hostname: backend-hostname
  logLevel: trace
```

#### Advanced setup example
The Advanced setup should be used if the settings of the Simple Setup are no longer sufficient.  
Therefore, if more than one virtual host, mapping and backend is needed, or if the app requires different settings than those that can be set with the `config.default.*`.   
Please note that a valid DSL app must be specified and the values config.default.* are no longer used.   

The following two examples show a possible use case where you could choose the Advanced Setup.  

Multiple Mappings:
```
apps:
  - backend:
      hostname: backend-hostname
      protocol: https
    mappings:
      - name: root
      - name: example
        entry_path: /example/
        operational_mode: integration
```

Deny Rule exceptions:
```
apps:
  - backend:
      hostname: backend-hostname
      protocol: https
    mappings:
      - name: root
        deny_rules:
          - level: strict
            exceptions:
              - parameter_name:
                  pattern: $exception.*parameter^
                parameter_value:
                  pattern: $exception.*value^  
```

#### Expert setup example
In the expert setup you must dispense of all config.* settings of the Helm chart, with the exception of the config.dsl setting.  
This means that if you have DSL requirements that cannot be covered by the first two setups, you can specify your own DSL.   

### External connectivity
This section describes how the external connectivity can be configured.   
There are two different scenarios if you are on Kubernetes or if you want to install on Openshift.   
On Kubernetes an Ingress Controller is used and on Openshift a Route object.   

### Kubernetes Ingress
In the Kubernetes environments an Ingress Controller is required to make the Microgateway accessible from the Internet.  
In our examples we will use the nginx-ingress-controller. However, this is not installed directly with the Helm chart.   
The Helm chart only offers the possibility to create the required configuration for an existing Ingress Controller.   
If no ingress controller is available in an environment, it can be installed with Helm.   

[nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress)
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm install nginx stable/nginx-ingress
```

#### Without TLS
The following configuration example shows how the Ingress can be configured without TLS.  

```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: nginx
  hosts:
      - virtinc.com
```

#### TLS Configuration
An Ingress can be protected with a Secret, which contains the TLS certificates.  
Currently the Ingress only supports a single TLS port, 443, and assumes TLS termination.  
If the TLS configuration section in an Ingress specifies different hosts, they are bundled on the same port according to the SNI-TLS extension.  

The following configuration example shows how the Ingress can be configured with TLS.
```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: nginx
  targetPort: https
  tls:
    - secretName: virtinc-tls-secret
      hosts:
        - virtinc.com
```

### Openshift Route
In Openshift a route is needed to reach the Microgateway from the Internet.
A route object must be created for its configuration. The creation of such an object is handled by the Microgateway Helm chart.  

#### Without TLS
This example shows how to configure a route object without TLS using the Helm chart.

```
route:
  enabled: true
  hosts:
    - virtinc.com
  targetPort: http
  tls:
    enabled: false
```

#### TLS Configuration
There are three different TLS configuration options for the openshift route. These are edge, reencrypt and passthrough.  
Below is a description of how these options can be configured using the Microgateway chart.  

Evtl. nur eine Möglichkeit. 
There are two different options for specifying TLS certificates in the Helm chart.   
Either you create a secret (config.tlsSecretName) containing the required certificates or you provide the certificates in a custom-values.yaml file during deployment.   

##### Edge
With the edge termination TLS is terminated on the router.   
The TLS certificates are served by the router and must therefore be configured on the router.   

```
route:
  enabled: true
  hosts:
    - virtinc.com
  tls:
    enabled: true
    termination: edge
    certificate: |
      -----BEGIN CERTIFICATE-----
      MIIDizCCAnOgAwIBAgIJAMQE1QewYs4QMA0GCSqGSIb3DQEBCwUAMFwxCzAJBgNV
      BAYTAkNIMQ8wDQYDVQQIDAZadXJpY2gxDzANBgNVBAcMBlp1cmljaDEQMA4GA1UE
      [...]
      CgwHQWlybG9jazEZMBcGA1UEAwwQdGVzdC5jZXJ0aWZpY2F0ZTAeFw0xNjAyMTYx
      77RRptcoQJPvw50z9rJ4wkrb58raUKOqxgvpckQdYdtok0dR6tXbBfC4LHmqq0mo
      -----END CERTIFICATE-----
    key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEAtXkTjHtDtutxyo1R6N4Eh18IzxoagAHPRzsdB5yeadcVr/bV
      oKV9XXmvx/VFEPOxyG8q4y/zU0qaESIF8FzOfdPciULVyMY2fWrrEByyQSpfhDvn
      [...]
      pN5G7+/iMFWMp3sGaheIGpVJfMV0Mq3t6rOPrjcvNx9tY5dtmno+DUxyPI1jEc1y
      pGKu7aodwB4cD5YnfXTvUcTv5tNU0llRLG1J0bg1n9cCo0nTC9sUZw==
      -----END RSA PRIVATE KEY-----       
```

##### Reencrypt
Reencrypt is similar to edge termination, because TLS termination takes place on the router.  
However, with reencrypt the connection is encrypted again before the request is sent to the Microgateway service.   
This means that the entire path of the connection is encrypted, including the internal network.   

```
route:
  enabled: true
  hosts:
    - virtinc.com
  tls:
    enabled: true
    certificate: |
      -----BEGIN CERTIFICATE-----
      MIIDizCCAnOgAwIBAgIJAMQE1QewYs4QMA0GCSqGSIb3DQEBCwUAMFwxCzAJBgNV
      BAYTAkNIMQ8wDQYDVQQIDAZadXJpY2gxDzANBgNVBAcMBlp1cmljaDEQMA4GA1UE
      [...]
      CgwHQWlybG9jazEZMBcGA1UEAwwQdGVzdC5jZXJ0aWZpY2F0ZTAeFw0xNjAyMTYx
      77RRptcoQJPvw50z9rJ4wkrb58raUKOqxg4Jn=
      -----END CERTIFICATE-----
    key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEAtXkTjHtDtutxyo1R6N4Eh18IzxoagAHPRzsdB5yeadcVr/bV
      oKV9XXmvx/VFEPOxyG8q4y/zU0qaESIF8FzOfdPciULVyMY2fWrrEByyQSpfhDvn
      [...]
      pN5G7+/iMFWMp3sGaheIGpVJfMV0Mq3t6rOPrjcvNx9tY5dtmno+DUxyPI1jEc1y
      pGKu7aodwB4cD5YnfXTvUcTv5tNU0llRLG1J0bg1n9cCo0nTC9sUZw==
      -----END RSA PRIVATE KEY-----
    destinationCACertificate: | 
      -----BEGIN CERTIFICATE-----    
      MIIDrIXdz54xcilsKUoepQkn9e0bmIUVuiXWcQrr8iqjYC+hINNmiq+4YX4lWq2M
      9Q2SA8zBjfRfZlGCORm7vdwIzPbRRo19TMXeBoOOnO8XB/XWS+n/bBLkRYN+wcnf
      [...]
      JqUxrIXdz54xcilsKUoepQkn9e0bmIUVuiXWcQrr8iqjYC+hINNmiq+4YX4lWq2M
      K0RRA/rDxZnkbvtTd+hkoMu3Or+pqpOrp2n1pbtzoVl9Hg==
      -----END CERTIFICATE-----
```

##### Passthrough
When Passthrough is configured, the encrypted traffic is sent directly to the Microgateway without being terminated on the route.   
This means that no certificate needs to be configured on the route and termination takes place only on the Microgateway.  

```
route:
  enabled: true
  path: ""
  hosts:
    - virtinc.com
  tls:
    enabled: true
    termination: passthrough
```

## Environment Variables
With the Helm chart environment variables can be set.   
These can then be used in the DSL configuration.   
Below is an example of how to set environment variables and then use them in the DSL.   

env-variables.yaml
```
config:
  env:
    - name: "WAF_CFG_OPERATIONALMODE"
      value: "production"
    - name: "WAF_CFG_LOGONLY"
      value: "false"
```

dsl-values.yaml
```
config:
  default: 
    mapping:
      operationalMode: "@@WAF_CFG_OPERATIONALMODE@@"
      denyRules:
        logOnly: "@@WAF_CFG_LOGONLY@@"
```

## Probes
In Kubernetes and Openshift probes are used to determine if a pod is ready to process requests or not.  

### Liveness Probe
The liveness Probe is used to find out when to restart a Pod.   
If a liveness Probe fails, the Pod will restart.   

The Helm chart has already predefined a liveness probe.   
If this does not work, it can be adjusted as follows.   

```
livenessProbe:
  initialDelaySeconds: 120
```

The liveness Probe can be disabled with `livenessProbe.enabled=false`  
Then the default of the environment on which the Microgateway is deployed is applied.   

### Readiness Probe
The readiness Probe is used to set the status of a pod to Ready. This means that the pod is now ready to process requests.  
If a readiness Probe fails, only the Ready status of the Pod is removed.   

The Helm chart has already predefined a readiness probe.   
If this does not work, it can be adjusted as follows.   

```
readinessProbe:
  initialDelaySeconds: 90
```

The readiness Probe can be disabled with `readinessProbe.enabled=false`  
Then the default of the environment on which the Microgateway is deployed is applied.   
