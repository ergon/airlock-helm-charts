Airlock microgateway
============

Airlock Microgateway, a WAF container solution to protect other services.

The current chart version is: 0.4.4

## Table of contents
* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Quick start guide](#quick-start-guide)
  * [Adding the chart repository](#adding-the-chart-repository)
  * [Installing the chart](#installing-the-chart)
  * [Uninstalling the chart](#uninstalling-the-chart)
* [Configuration](#configuration)
* [Getting started](#getting-started)
  * [Override default values](#override-default-values)
* [Dependencies](#dependencies)
  * [Redis](#redis)
  * [Echo-Server](#echo-server)
* [DSL configuration](#dsl-configuration)
  * [Simple DSL configuration](#simple-dsl-configuration)
  * [Advanced DSL configuration](#advanced-dsl-configuration)
  * [Expert DSL configuration](#expert-dsl-configuration)
* [Environment variables](#environment-variables)
* [Probes](#probes)
  * [Readiness Probe](#readiness-probe)
  * [Liveness Probe](#liveness-probe)
* [External connectivity](#external-connectivity)
  * [Kubernetes Ingress](#kubernetes-ingress)
    * [Ingress terminating HTTP](#ingress-terminating-http)
    * [Ingress terminating secure HTTPS](#ingress-terminating-secure-https)
  * [Openshift Route](#openshift-route)
    * [Route terminating HTTP](#route-terminating-http)
    * [Route terminating secure HTTPS](#route-terminating-secure-https)
      * [Route Edge configuration](#route-edge-configuration)
      * [Route Reencrypt configuration](#route-reencrypt-configuration)
      * [Route Passthrough configuration](#route-passthrough-configuration)

## Introduction
This Helm chart bootstraps [Airlock Microgateway](https://www.airlock.com) on a [Kubernetes](https://kubernetes.io) or [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh) package manager. It provisions an Airlock Microgateway pod with a default configuration which can be adjusted to customer needs. For more details about the configuration options, see chapter [Helm Configuration](#dsl-configuration).

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
  helm upgrade -i microgateway airlock/microgateway -f license.yaml
  ```

:exclamation: Airlock Microgateway will not work without a valid license. To order one, get in contact with sales@airlock.com.

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
| commonLabels | object | `{}` | Labels to add to all resources |
| config.advanced.apps | list | `[]` | [Advanced DSL configuration](#advanced-dsl-configuration) |
| config.expert.dsl | object | `{}` | [Expert DSL configuration](#expert-dsl-configuration) |
| config.generic | object | See `config.generic.*`: | Available for:<br> - [Simple DSL configuration](#simple-dsl-configuration)<br> - [Advanced DSL configuration](#advanced-dsl-configuration)<br> - [Expert DSL configuration](#expert-dsl-configuration) |
| config.generic.env | list | `[]` | [Environment variables](#environment-variables) |
| config.generic.existingSecret | string | "" | Name of an existing secret containing:<br><br> license: `license`<br> passphrase: `passphrase` |
| config.generic.license | string | "" | License (multiline string) |
| config.generic.passphrase | string | - `passphrase`<br> If `passphrase` in `config.generic.existingSecret` <br><br> - `<generated passphrase>`<br> If no passphrase available. | Passphrase used for encryption |
| config.generic.tlsSecretName | string | "" | Name of an existing secret containing:<br><br> _Virtual Host:_<br> Certificate: `tls.crt`<br> Private key: `tls.key`<br> CA: `ca.crt` <br> :exclamation: Update`route.tls.destinationCACertificate` accordingly.<br><br> _Backend:_<br> Certificate: `backend-client.crt`<br> Private key: `backend-client.key`<br> CA: `backend-server-validation-ca.crt` |
| config.global | object | See `config.global.*`: | Available for:<br> - [Simple DSL configuration](#simple-dsl-configuration)<br> - [Advanced DSL configuration](#advanced-dsl-configuration) |
| config.global.IPHeader.header | string | `"X-Forwarded-For"` | HTTP header to extract the client IP address. |
| config.global.IPHeader.trustedProxies | list | `[]` | Trusted IP addresses to extract the client IP from HTTP header.<br><br> :exclamation: IP addresses are only extracted if `trustedProxies` are configured. |
| config.global.backend.tls.cipherSuite | string | `""` | Overwrite the default TLS ciphers (<=TLS 1.2) for backend connections. |
| config.global.backend.tls.cipherSuitev13 | string | `""` | Overwrite the default TLS ciphers (TLS 1.3) for backend connections. |
| config.global.backend.tls.clientCert | bool | `false` | Use TLS client certificate for backend connections. <br> :exclamation: Must be configured in `config.generic.tlsSecretName` |
| config.global.backend.tls.serverCa | bool | `false` | Validates the backend server certificate against the configured CA. <br> :exclamation: Must be configured in `config.generic.tlsSecretName` |
| config.global.backend.tls.verifyHost | bool | `false` | Verify the backend TLS certificate.<br> :exclamation: `config.global.backend.tls.serverCa` must be configured in order to work. |
| config.global.backend.tls.version | string | `""` | Overwrite the default TLS version for backend connections.<br> |
| config.global.expert_settings.apache | string | "" | Global Apache Expert Settings (multiline string) |
| config.global.expert_settings.security_gate | string | "" | Global SecurityGate Expert Settings (multiline string) |
| config.global.logLevel | string | `"info"` | Log level (`info`, `trace`).<br> :exclamation: Never use `trace` in production. |
| config.global.redisService | list | - `redis-master`<br> If `redis.enabled=true`<br><br> - `""`<br> If `redis.enabled=false` | List of Redis services. |
| config.global.virtualHost.tls.cipherSuite | string | `""` | Overwrite the default TLS ciphers for frontend connections. |
| config.global.virtualHost.tls.protocol | string | `""` | Overwrite the default TLS protocol for frontend connections. |
| config.simple | object | See `config.simple.*`: | [Simple DSL configuration](#simple-dsl-configuration) |
| config.simple.backend.hostname | string | `"backend-service"` | Backend hostname |
| config.simple.backend.port | int | `8080` | Backend port |
| config.simple.backend.protocol | string | `"http"` | Backend protocol |
| config.simple.mapping.denyRules.enabled | bool | `true` | Enable all Deny rules |
| config.simple.mapping.denyRules.exceptions | list | `[]` | Deny rule exceptions |
| config.simple.mapping.denyRules.level | string | `"standard"` | Security Level for all Deny rules (`basic`, `standard`, `strict`) |
| config.simple.mapping.denyRules.logOnly | bool | `false` | Enable log only for all Deny rules |
| config.simple.mapping.entryPath | string | `"/"` | The `entry_path` of the app. |
| config.simple.mapping.operationalMode | string | `"production"` | Operational mode (`production`, `integration`) |
| config.simple.mapping.sessionHandling | string | - `enforce_session`<br> If `redis.enabled=true` <br> or `config.global.redisService`<br><br> - `ignore_session`<br> If `redis.enabled=false` | Session handling (`enforce_session`, `ignore_session`, `optional_session`, `optional_session_no_refresh`) |
| echo-server | object | See `echo-server.*`: | Pre-configured [Echo-Server](#echo-server). |
| echo-server.enabled | bool | `false` | Deploy pre-configured [Echo-Server](#echo-server). |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources |
| image.pullPolicy | string | `"Always"` | Pull policy (`Always`, `IfNotPresent`, `Never`) |
| image.repository | string | `"docker.ergon.ch/airlock/microgateway"` | Image repository |
| image.tag | string | `"7.4.sprint10_Build008"` | Image tag |
| imagePullSecrets | list | `[]` | Reference to one or more secrets to use when pulling images |
| ingress | object | See `ingress.*`: | [Kubernetes Ingress](#kubernetes-ingress) |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/rewrite-target":"/"}` | Annotations to set on the ingress |
| ingress.enabled | bool | `false` | Create an ingress object |
| ingress.hosts | list | `["virtinc.com"]` | List of ingress hosts |
| ingress.labels | object | `{}` | Additional labels to add on the Microgateway ingress |
| ingress.path | string | `"/"` | Path for the ingress |
| ingress.targetPort | string | `"http"` | Target port of the service (`http`, `https` or `<number>`) |
| ingress.tls | list | `[]` | [Ingress TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration |
| livenessProbe.enabled | bool | `true` | Enable liveness probes |
| livenessProbe.initialDelaySeconds | int | `90` | Initial delay in seconds |
| nameOverride | string | `""` | Provide a name in place of `microgateway` |
| nodeSelector | object | `{}` | Define which nodes the pods are scheduled on |
| podSecurityContext | object | `{}` | [Security context for the pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| readinessProbe.enabled | bool | `true` | Enable readiness probes |
| readinessProbe.initialDelaySeconds | int | `30` | Initial delay in seconds |
| redis | object | See `redis.*`: | Pre-configured [Redis](#redis) service. |
| redis.enabled | bool | `false` | Deploy pre-configured [Redis](#redis). |
| redis.securityContext.fsGroup | int | `1000140000` | Group ID for the container<br> (Redis master and slave pods) |
| redis.securityContext.runAsUser | int | `1000140000` | User ID for the container<br> (Redis master and slave pods) |
| replicaCount | int | `1` | Desired number of Microgateway pods |
| resources | object | `{"limits":{"cpu":"4","memory":"4048Mi"},"requests":{"cpu":"500m","memory":"512Mi"}}` | [Resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) |
| route | object | See `route.*`: | [Openshift Route](#openshift-route) |
| route.annotations | object | `{}` | Annotations to set on the route |
| route.enabled | bool | `false` | Create a route object |
| route.hosts | list | `["virtinc.com"]` |  List of host names |
| route.labels | object | `{}` | Additional labels add on the Microgateway route |
| route.path | string | `"/"` | Path for the route |
| route.targetPort | string | `"https"` | Target port of the service (`http`, `https` or `<number>`) |
| route.tls.certificate | string | "" | Certificate to be used (multiline string) |
| route.tls.destinationCACertificate | string | Microgateway's default certificate | Validate the Microgateway server certificate against this CA. (multiline string).<br> :exclamation: Must be configured with termination `reencrypt`. |
| route.tls.enabled | bool | `true` | Enable TLS for the route |
| route.tls.insecureEdgeTerminationPolicy | string | `"Redirect"` | Define the insecureEdgeTerminationPolicy of the route (`Allow`, `Redirect`, `None`) |
| route.tls.key | string | "" | Private key to be used for certificate (multiline string) |
| route.tls.termination | string | `"reencrypt"` | Termination of the route (`edge`, `reencrypt`, `passthrough`) |
| securityContext | object | `{}` | [Security context for a container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| service.annotations | object | `{}` | Annotations to set on the service |
| service.labels | object | `{}` | Additional labels to add on the service |
| service.port | int | `80` | Service port |
| service.tlsPort | int | `443` | Service TLS port |
| service.type | string | `"ClusterIP"` | [Service type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) |
| tolerations | list | `[]` | Tolerations for use with node [taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) |

## Getting started
This chapter provides information to get started with the Helm chart.

### Override default values
The Airlock Microgateway Helm chart has many parameters and most of them have default values (see [Configuration](#configuration)). Depending on the environment, the defaults must be adapted. To override default values, do the following:

* Create a yaml file which contains the values differ to the default.
* Apply this yaml file with the `-f` parameter.

**Example:**

  custom-values.yaml
  ```
  config:
    simple:
      backend:
        hostname: custom-backend-service
    generic:
      existingSecret: "microgateway-secrets"
  imagePullSecrets:
    - name: "docker-secret"
  ingress:
    enabled: true
    hosts:
      - example.virtinc.com
  ```

Afterwards apply the Helm chart configuration file with the `-f` parameter.
  ```console
  helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml
  ```

:point_up: **YAML indentation**:<br>
YAML is very strict with indetation. To ensure that the YAML file itself is correct, check it's content with a YAML validator (e.g. [YAML Lint](http://www.yamllint.com/)).

## Dependencies
The Airlock Microgateway Helm chart has the following optional dependencies, which can be enabled for an easy start.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | redis | 10.6.0 |
| https://ealenn.github.io/charts | echo-server | 0.3.0 |

### Redis
In case that session handling is enabled on Airlock Microgateway, a Redis service needs to be available. The Airlock Microgateway Helm chart has two options:
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
    global:
      redisService:
        - <REDIS-SERVICE1>:<PORT>
        - <REDIS-SERVICE2>:<PORT>
  redis:
    enabled: false
  ```

Finally, apply the Helm chart configuration file with `-f` parameter.

  ```console
  helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml
  ```

:information_source: **Possible settings**:<br>
Please refer to the [Redis Helm chart](https://hub.helm.sh/charts/bitnami/redis) to see all possible parameters of the Redis Helm chart.

:warning: **Adjustments of the default settings**:<br>
Please note that the dependend Redis service has been tested with the settings this Helm chart is delivered. Adjusting those settings can cause issues.

### Echo-Server
For the first deployment it could be very useful to have a backend service processing requests. For this purpose the dependend echo-server can be deployed by doing the following:
  custom-values.yaml
  ```
  echo-server:
    enabled: true
  ```

Finally, apply the Helm chart configuration file with `-f` parameter.

  ```console
  helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml
  ```

:information_source: **Possible settings**:<br>
Please refer to the [Echo-Server Helm chart](https://ealenn.github.io/Echo-Server/pages/helm.html) to see all possible parameters of the Echo-Server Helm chart.

## DSL configuration
The Helm chart provides three different possibilities to configure the Microgateway.
Depending on the environment and use case, another option might suit better and is easier to implement.

### Simple DSL configuration
The simple DSL configuration suites best for the following use case:
* Virtual Host 1: abc.com -> Mapping 1: / -> Backend Service 1

Restrictions for Simple DSL configuration:
* Only one Virtual Host is configured.
* Only one Mapping is configured.
* Only one backend service is configured.

By default, the Airlock Microgateway is configured with the [Simple DSL configuration](#simple-dsl-configuration). The example below shows how to adjusted the default values:

**Example:**

  custom-values.yaml
  ```
  config:
    global:
      IPHeader:
        trustedProxies:
          - 10.0.0.0/28
    simple:
      mapping:
        entryPath: /
          operationalMode: integration
        denyRules:
          level: strict
          exceptions:
            - parameter_name:
                pattern: ^content$
                ignore_case: true
              path:
                pattern: ^/mail/
              method:
                pattern: ^POST$
      backend:
        protocol: https
        hostname: custom-backend-service
        port: 8443
  
  redis:
    enabled: true
  ```

**`config.*` Parameters which can be used**:
* `config.simple.*`
* `config.global.*`
* `config.generic.*`

### Advanced DSL configuration
In case that the [Simple DSL configuration](#simple-dsl-configuration) does not suite, the advanced configuration options might help. The following use cases might require this kind of configuration:

**_Use Case 1)_**
* Virtual Host 1: abc.com -> Mapping 1: / -> Backend Service 1
* Virtual Host 2: xyz.com -> Mapping 2: / -> Backend Service 1

**_Use Case 2)_**
* Virtual Host 1: abc.com -> Mapping 1: /      -> Backend Service 1
                          -> Mapping 2: /auth/ -> Backend Service 1

**_Use Case 3)_**
* Virtual Host 1: abc.com -> Mapping 1: / -> Backend Service 1
* Virtual Host 2: xyz.com -> Mapping 2: / -> Backend Service 2

The use cases outlined above can occur also slightly different. But all of them have in common that more than one Virtual Hosts, Mappings or Backend Services are used. Whenever this is the case, the [Advanced DSL configuration](#advanced-dsl-configuration) should be preferred over the [Simple DSL configuration](#simple-dsl-configuration).

**Example:**

  custom-values.yaml
  ```
  config:
    global:
      IPHeader:
        trustedProxies:
          - 10.0.0.0/28
    advanced:
      apps:
        - virtual_host:
            hostname: virtinc.com
          mappings:
            - name: webapp
              entry_path: /
              operational_mode: integration
              session_handling: enforce_session
              denyRules:
                level: standard
                exceptions:
                  - parameter_name:
                      pattern: ^content$
                      ignore_case: true
                    path:
                      pattern: ^/mail/
                    method:
                      pattern: ^POST$
            - name: api
              entry_path: /api/
              session_handling: ignore_session
              denyRules:
                level: strict
              openapi:
                spec_file: /config/virtinc_api_openapi.json
          backend:
            protocol: https
            hostname: custom-backend-service
            port: 8443
  
  redis:
    enabled: true
  ```

**`config.*` Parameters which can be used**:
* `config.advanced.apps` - **must** be used.
* `config.global.*`
* `config.generic.*`

### Expert DSL configuration
In case that the [Advanced DSL configuration](#advanced-dsl-configuration) does not suite, the expert configuration options must be used. There are a few reasons listed below:

* The Microgateway DSL configuration options are not available as Helm chart parameters (e.g. base_template_file, session.store_mode, ...)
* The Microgateway DSL configuration file has already been used/tested elsewhere. To reduce the risk, the same configuration file should be used.


**Example:**

  custom-values.yaml
  ```
  config:
    expert:
      dsl:
        base_template_file: /config/custom-base.xml
        license_file: /secret/config/license
        session:
          encryption_passphrase_file: /secret/config/passphrase
          redis_host:
            - redis-master
        log:
          level: info
        expert_settings:
          apache: |
            RemoteIPHeader X-Forwarded-For
            RemoteIPInternalProxy 10.0.0.0/28
          
        apps:
          - virtual_host:
              hostname: virtinc.com
            mappings:
              - name: webapp
                entry_path: /
                operational_mode: integration
                session_handling: enforce_session
              - name: api
                entry_path: /api/
                session_handling: ignore_session
                openapi:
                  spec_file: /config/virtinc_api_openapi.json
            backend:
              protocol: https
              hostname: custom-backend-service
              port: 8443
  
  redis:
    enabled: true
  
  ```

**`config.*` Parameters which can be used**:
* `config.expert.dsl - **must** be used.
* `config.generic.*`

## Environment variables
Environment variables can be configured with the Helm chart and used within the [DSL Configuration](#dsl-configuration).
This works for all three DSL configuration setups (simple, advanced and expert). The example below illustrates how to 
configure environment variables in combination with the [Simple DSL configuration](#simple-dsl-configuration).

  env-variables.yaml
  ```
  config:
    generic:
      env:
        - name: WAF_CFG_OPERATIONALMODE
          value: production
        - name: WAF_CFG_LOGONLY
          value: false
  ```

  custom-values.yaml
  ```
  config:
    simple: 
      mapping:
        operationalMode: "@@WAF_CFG_OPERATIONALMODE@@"
        denyRules:
          logOnly: "@@WAF_CFG_LOGONLY@@"
  ```

Finally, apply the Helm chart configuration file with `-f` parameter.

  ```console
  helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml -f env-variables.yaml
  ```

## Probes
Probes are used in Kubernetes and Openshift to determine if a pod is ready and in good health to process requests.

### Readiness Probe
The readiness probe determines whether a pod is ready to process requests. This means that requests are only forwarded to this pod once it is in ready state.

The Helm chart is already pre-configured for the readiness probe endpoint of the Microgateway Pod. A huge Microgateway configuration could require to increase the initial delay. 
This can be accomplished by configuring the following parameter:

  ```
  readinessProbe:
    initialDelaySeconds: 90
  ```

If desired, the readiness probe can be disabled with `readinessProbe.enabled=false`.

### Liveness Probe
The liveness Probe determines whether a pod is in good health. If the liveness probe fails, the Pod is terminated and one is started.

The Helm chart is already pre-configured for the liveness probe endpoint of the Microgateway Pod. A huge Microgateway configuration could require to increase the initial delay. 
This can be accomplished by configuring the following parameter:

  ```
  livenessProbe:
    initialDelaySeconds: 120
  ```

If desired, the liveness probe can be disabled with `livenessProbe.enabled=false`.

## External connectivity
The Helm chart can be configured to create a Kubernetes Ingress or Openshift Route to pass external traffic to the Microgateway Pod.
In case that those objects were created with this Helm chart, just follow along with the description and configuration examples. 
If there is already an existing Ingress or Route object and the traffic should only be passed to the Microgateway service, the information in the subchapters should provide useful information to integrate in the existing environment.

:information_source: **Kubernetes vs. Openshift**:<br>
This Helm chart can be used for Kubernetes and Openshift. While Kubernetes has "Ingress" and Openshift has "Route", simply enable the feature which fits to the environment (e.g. in Kubernetes `ingress.enabled=true` and in Openshift `route.enabled=true`).

### Kubernetes Ingress
Kubernetes allows to use different kind of Ingress controllers. Our examples are based on the [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) controller.

  The example below shows how to install the nginx-ingress-controller with Helm:
  ```
  helm repo add stable https://kubernetes-charts.storage.googleapis.com
  helm install nginx stable/nginx-ingress
  ```

:information_source: **Note**:<br>
The Microgateway Helm chart itself does not install the nginx-ingress-controller, but allows to create an Ingress object.

#### Ingress terminating HTTP

  To receive HTTP traffic from the outside of the Kubernetes cluster, use the following configuration:
  ```
  ingress:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      kubernetes.io/ingress.class: nginx
    hosts:
        - virtinc.com
  ```

#### Ingress terminating secure HTTPS
The TLS certificate of the Ingress must be in a secret object which is referred in the Ingress configuration.
At the time of writing, Ingress supports only the default port 443 for HTTPS and directly assumes it is TLS.
In case that multiple hosts are configured, TLS-SNI is used to distinguish what host the client requested.

  To receive HTTPS traffic from the outside of the Kubernetes cluster, use the following configuration:
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
The examples are based on the standard Openshift Route. Since this is already available in a Openshift environment, nothing special needs to be done. The Microgateway Helm chart allows to create a Route object.

#### Route terminating HTTP

  To receive HTTP traffic from the outside of the Openshift cluster, use the following configuration:
  ```
  route:
    enabled: true
    hosts:
      - virtinc.com
    targetPort: http
    tls:
      enabled: false
  ```

#### Route terminating secure HTTPS
Openshift has there three different TLS termination types which can be used. Edge, reencrypt and passthrough.
The subchapters provide the required information to configure it, using the Microgateway Helm chart.

##### Route Edge configuration
With the TLS termination type "Edge", HTTPS traffic is terminated on the Openshift Router.
Therefore, a valid certificate for the specified hosts must be applied.

  To setup Edge TLS termination, use the following configuraion:
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
        [...]
        77RRptcoQJPvw50z9rJ4wkrb58raUKOqxgvpckQdYdtok0dR6tXbBfC4LHmqq0mo
        -----END CERTIFICATE-----
      key: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAtXkTjHtDtutxyo1R6N4Eh18IzxoagAHPRzsdB5yeadcVr/bV
        [...]
        pGKu7aodwB4cD5YnfXTvUcTv5tNU0llRLG1J0bg1n9cCo0nTC9sUZw==
        -----END RSA PRIVATE KEY-----
  ```

##### Route Reencrypt configuration
With the TLS termination type "Reencrypt", HTTPS is terminated on the Openshift Router and re-encrypted to the Microgateway service.
Because the default in the Microgateway Helm chart for `route.targetPort` is `https`, traffic inside the Openshift cluster is by default encrypted.
The difference to TLS termination type "Edge" is:
* The Microgateway certificate is validated against `route.tls.destinationCACertificate`.
* It is enforced, that `route.targetPort=https` (Edge would also work with `route.targetPort=http`)

In other words, the entire path of the connection is encrypted and verified, also within the Openshift cluster.

  To setup Reencrypt TLS termination, use the following configuraion:
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
        [...]
        77RRptcoQJPvw50z9rJ4wkrb58raUKOqxg4Jn=
        -----END CERTIFICATE-----
      key: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAtXkTjHtDtutxyo1R6N4Eh18IzxoagAHPRzsdB5yeadcVr/bV
        [...]
        pGKu7aodwB4cD5YnfXTvUcTv5tNU0llRLG1J0bg1n9cCo0nTC9sUZw==
        -----END RSA PRIVATE KEY-----
      destinationCACertificate: | 
        -----BEGIN CERTIFICATE-----
        MIIDrIXdz54xcilsKUoepQkn9e0bmIUVuiXWcQrr8iqjYC+hINNmiq+4YX4lWq2M
        [...]
        K0RRA/rDxZnkbvtTd+hkoMu3Or+pqpOrp2n1pbtzoVl9Hg==
        -----END CERTIFICATE-----
  ```

##### Route Passthrough configuration
With the TLS termination type "Passthrough", HTTPS traffic is sent directly to the Microgateway, without decrypting it on the Route.
Therefore, no certificates need to be configured on the Route and termination takes place in the Microgateway.

  To setup Passthrough TLS termination, use the following configuraion:
  ```
  route:
    enabled: true
    hosts:
      - virtinc.com
    tls:
      enabled: true
      termination: passthrough
  ```


## Security (TBD)

### Hardening (TBD)

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
    generic:
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
    generic:
      tlsSecretName: "microgatewaytls"
  ```
