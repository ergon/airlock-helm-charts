# Airlock Microgateway

The *Airlock Microgateway* is a component of the [Airlock Secure Access Hub](https://www.airlock.com/).
It is the lightweight, container-based deployment form of the *Airlock Gateway*, a software appliance with reverse-proxy, Web Application Firewall (WAF) and API security functionality.


The Airlock helm charts are used internally for testing the *Airlock Microgateway*. We make them available publicly under the [MIT license](https://github.com/ergon/airlock-helm-charts/blob/master/LICENSE).

The current chart version is: 0.7.0

## About Ergon
*Airlock* is a registered trademark of [Ergon](https://www.ergon.ch). Ergon is a Swiss leader in leveraging digitalisation to create unique and effective client benefits, from conception to market, the result of which is the international distribution of globally revered products.

## Table of contents
* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Quick start guide](#quick-start-guide)
  * [Adding the chart repository](#adding-the-chart-repository)
  * [Installing the chart](#installing-the-chart)
  * [Uninstalling the chart](#uninstalling-the-chart)
* [Configuration](#configuration)
* [Getting started](#getting-started)
  * [Configure a valid license](#configure-a-valid-license)
  * [Override default values](#override-default-values)
* [Dependencies](#dependencies)
  * [Redis](#redis)
  * [Echo-Server](#echo-server)
* [DSL Configuration](#dsl-configuration)
  * [Simple DSL Configuration](#simple-dsl-configuration)
  * [Expert DSL Configuration](#expert-dsl-configuration)
* [Environment Variables](#environment-variables)
  * [DSL Environment Variables](#dsl-environment-variables)
  * [Runtime Environment Variables](#runtime-environment-variables)
* [Extra Volumes](#extra-volumes)
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
      * [Route Re-encrypt configuration](#route-re-encrypt-configuration)
      * [Route Passthrough configuration](#route-passthrough-configuration)
* [Security](#security)
  * [Store sensitive information in secrets](#store-sensitive-information-in-secrets)
    * [Secure handling of license and passphrase](#secure-handling-of-license-and-passphrase)
    * [Credentials to pull image from Docker registry](#credentials-to-pull-image-from-docker-registry)
    * [Certificates for Microgateway](#certificates-for-microgateway)

## Introduction
This Helm chart bootstraps [Airlock Microgateway](https://www.airlock.com) on a [Kubernetes](https://kubernetes.io) or [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh) package manager. It provisions an Airlock Microgateway Pod with a default configuration that can be adjusted to customer needs. For more details about the configuration options, see chapter [Helm Configuration](#dsl-configuration).

## Prerequisites
* The Airlock Microgateway image
* A valid license for Airlock Microgateway
* Redis service for session handling (see chapter [Dependencies](#dependencies))

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

:exclamation: Airlock Microgateway will not work without a valid license. For further information see chapter [Configure a valid license](#configure-a-valid-license)

### Uninstalling the chart
To uninstall the chart with the release name `microgateway`:

  ```console
  helm uninstall microgateway
  ```

## Configuration
The following table lists configuration parameters of the Airlock Microgateway chart and the default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | string | `nil` | Assign custom [affinity rules](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) (multiline string). |
| commonLabels | object | `{}` | Labels to add to all resources. |
| config.expert.dsl | object | `{}` | [Expert DSL configuration](#expert-dsl-configuration) |
| config.generic | object | See `config.generic.*`: | Available for:<br> - [Simple DSL configuration](#simple-dsl-configuration)<br> - [Expert DSL configuration](#expert-dsl-configuration) |
| config.generic.configEnv | list | `[]` | [DSL Environment Variables](#dsl-environment-variables) |
| config.generic.existingSecret | string | "" | Name of an existing secret containing:<br><br> license: `license`<br> passphrase: `passphrase` |
| config.generic.license | string | "" | License (multiline string) |
| config.generic.passphrase | string | - `passphrase`<br> If `passphrase` in `config.generic.existingSecret` <br><br> - `<generated passphrase>`<br> If no passphrase available. | Passphrase used for encryption. |
| config.generic.runtimeEnv | list | `[]` | [Runtime Environment Variables](#runtime-environment-variables) |
| config.generic.tlsSecretName | string | "" | Name of an existing secret containing:<br><br> _Virtual Host:_<br> Certificate: `frontend-server.crt`<br> Private key: `frontend-server.key`<br> CA: `frontend-server-ca.crt` <br> :exclamation: Update `route.tls.destinationCACertificate` accordingly.<br><br> _Backend:_<br> Certificate: `backend-client.crt`<br> Private key: `backend-client.key`<br> CA: `backend-server-validation-ca.crt` |
| config.global | object | See `config.global.*`: | Available for [Simple DSL configuration](#simple-dsl-configuration)<br> |
| config.global.backend.tls.cipher_suite | string | `""` | Overwrite the default TLS ciphers (<=TLS 1.2) for backend connections. |
| config.global.backend.tls.cipher_suite_v13 | string | `""` | Overwrite the default TLS ciphers (TLS 1.3) for backend connections. |
| config.global.backend.tls.client_cert | bool | `false` | Use TLS client certificate for backend connections. <br> :exclamation: Must be configured in `config.generic.tlsSecretName`. |
| config.global.backend.tls.server_ca | bool | `false` | Validates the backend server certificate against the configured CA. <br> :exclamation: Must be configured in `config.generic.tlsSecretName`. |
| config.global.backend.tls.verify_host | bool | `false` | Verify the backend TLS certificate.<br> :exclamation: `config.global.backend.tls.server_ca` must be configured in order to work. |
| config.global.backend.tls.version | string | `""` | Overwrite the default TLS version for backend connections.<br> |
| config.global.expert_settings.apache | string | "" | Global Apache Expert Settings (multiline string). |
| config.global.expert_settings.security_gate | string | "" | Global SecurityGate Expert Settings (multiline string). |
| config.global.ip_header.header | string | `"X-Forwarded-For"` | HTTP header to extract the client IP address. |
| config.global.ip_header.trusted_proxies | list | `[]` | Trusted IP addresses to extract the client IP from HTTP header.<br><br> :exclamation: IP addresses are only extracted if `trusted_proxies` are configured. |
| config.global.log_level | string | `"info"` | Log level (`info`, `trace`).<br> :exclamation: Never use `trace` in production. |
| config.global.redis_hosts | list | `[]` if `redis.enabled=false` or <br> `[ redis-master ]` if `redis.enabled=true` | List of Redis hosts. |
| config.global.virtual_host.tls.cipher_suite | string | `""` | Overwrite the default TLS ciphers for frontend connections. |
| config.global.virtual_host.tls.protocol | string | `""` | Overwrite the default TLS protocol for frontend connections. |
| config.simple | object | See `config.simple.*`: | [Simple DSL configuration](#simple-dsl-configuration) |
| config.simple.backend.hostname | string | `"backend-service"` | Backend hostname |
| config.simple.backend.port | int | `8080` | Backend port |
| config.simple.backend.protocol | string | `"http"` | Backend protocol |
| config.simple.mapping.deny_rules.enabled | bool | `true` | Enable all Deny rules. |
| config.simple.mapping.deny_rules.exceptions | list | `[]` | Deny rule exceptions. |
| config.simple.mapping.deny_rules.level | string | `"standard"` | Security Level for all Deny rules (`basic`, `standard`, `strict`). |
| config.simple.mapping.deny_rules.log_only | bool | `false` | Enable log only for all Deny rules. |
| config.simple.mapping.entry_path | string | `"/"` | The `entry_path` of the app. |
| config.simple.mapping.operational_mode | string | `"production"` | Operational mode (`production`, `integration`). |
| config.simple.mapping.session_handling | string | - `enforce_session`<br> If `redis.enabled=true` <br> or `config.global.redis_hosts`<br><br> - `ignore_session`<br> If `redis.enabled=false` | Session handling (`enforce_session`, `ignore_session`, `optional_session`, `optional_session_no_refresh`). |
| echo-server | object | See `echo-server.*`: | Pre-configured [Echo-Server](#echo-server). |
| echo-server.enabled | bool | `false` | Deploy pre-configured [Echo-Server](#echo-server). |
| extraVolumeMounts | list | `[]` | Add additional volume mounts. |
| extraVolumes | list | `[]` | Add additional volumes. [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources. |
| hpa | object | See `hpa.*`: | [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to scale <br> Microgateway based on Memory and CPU consumption.<br><br> :exclamation: Check [API versioning](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#api-versioning) when using this Beta feature. |
| hpa.enabled | bool | `false` | Deploy a horizontal pod autoscaler. |
| hpa.maxReplicas | int | `10` | Maximum number of Microgateway replicas. |
| hpa.minReplicas | int | `1` | Minimum number of Microgateway replicas. |
| hpa.resource.cpu | int | `50` | Average Microgateway CPU consumption in percentage to scale up/down. |
| hpa.resource.memory | string | `"2Gi"` | Average Microgateway Memory consumption to scale up/down.<br><br> :exclamation: Update this setting accordingly to `resources.limits.memory`. |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy (`Always`, `IfNotPresent`, `Never`) |
| image.repository | string | `"ergon/airlock-microgateway"` | Image repository for the Airlock Microgateway runtime image |
| image.repository_configbuilder | string | `"ergon/airlock-microgateway-configbuilder"` | Image repository for the Airlock Microgateway configbuilder image |
| image.tag | string | `"2.0"` | Image tag for runtime and config builder image |
| imagePullSecrets | list | `[]` | Reference to one or more secrets to use when pulling images. |
| ingress | object | See `ingress.*`: | [Kubernetes Ingress](#kubernetes-ingress) |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/rewrite-target":"/"}` | Annotations to set on the ingress. |
| ingress.enabled | bool | `false` | Create an ingress object. |
| ingress.hosts | list | `["virtinc.com"]` | List of ingress hosts. |
| ingress.labels | object | `{}` | Additional labels to add on the Microgateway ingress. |
| ingress.path | string | `"/"` | Path for the ingress. |
| ingress.targetPort | string | `"http"` | Target port of the service (`http`, `https` or `<number>`). |
| ingress.tls | list | `[]` | [Ingress TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration. |
| livenessProbe.enabled | bool | `true` | Enable liveness probes. |
| livenessProbe.failureThreshold | int | `9` | After how many subsequent failures the pod gets restarted. |
| livenessProbe.initialDelaySeconds | int | `90` | Initial delay in seconds. |
| livenessProbe.timeoutSeconds | int | `5` | Timeout of liveness probes, should roughly reflect allowed timeouts from clients. |
| nameOverride | string | `""` | Provide a name in place of `microgateway`. |
| nodeSelector | object | `{}` | Define which nodes the pods are scheduled on. |
| podSecurityContext | object | `{}` | [Security context for the pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod). |
| readinessProbe.enabled | bool | `true` | Enable readiness probes. |
| readinessProbe.failureThreshold | int | `3` | After how many tries the pod stops receiving traffic. |
| readinessProbe.initialDelaySeconds | int | `10` | Initial delay in seconds. |
| redis | object | See `redis.*`: | Pre-configured [Redis](#redis) service. |
| redis.enabled | bool | `false` | Deploy pre-configured [Redis](#redis). |
| replicaCount | int | `1` | Desired number of Microgateway pods. |
| resources | object | `{"limits":{"memory":"4048Mi"},"requests":{"cpu":"30m","memory":"256Mi"}}` | [Resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) |
| route | object | See `route.*`: | [Openshift Route](#openshift-route) |
| route.annotations | object | `{}` | Annotations to set on the route. |
| route.enabled | bool | `false` | Create a route object. |
| route.hosts | list | `["virtinc.com"]` |  List of host names. |
| route.labels | object | `{}` | Additional labels add on the Microgateway route. |
| route.path | string | `"/"` | Path for the route. |
| route.targetPort | string | `"https"` | Target port of the service (`http`, `https` or `<number>`). |
| route.tls.certificate | string | "" | Certificate to be used (multiline string). |
| route.tls.destinationCACertificate | string | Microgateway's default certificate | Validate the Microgateway server certificate against this CA. (multiline string).<br> :exclamation: Must be configured with termination `reencrypt`. |
| route.tls.enabled | bool | `true` | Enable TLS for the route. |
| route.tls.insecureEdgeTerminationPolicy | string | `"Redirect"` | Define the insecureEdgeTerminationPolicy of the route (`Allow`, `Redirect`, `None`). |
| route.tls.key | string | "" | Private key to be used for certificate (multiline string). |
| route.tls.termination | string | `"reencrypt"` | Termination of the route (`edge`, `reencrypt`, `passthrough`). |
| securityContext | object | `{}` | [Security context for a container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container). |
| service.annotations | object | `{}` | Annotations to set on the service. |
| service.labels | object | `{}` | Additional labels to add on the service. |
| service.port | int | `80` | Service port |
| service.tlsPort | int | `443` | Service TLS port |
| service.type | string | `"ClusterIP"` | [Service type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) |
| tolerations | list | `[]` | Tolerations for use with node [taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/). |

## Getting started
This chapter provides information how to get started with the Helm chart.

### Configure a valid license
This section describes how to configure a license for the Microgateway. By following the steps below, the Helm chart creates a secret with the license which is used by the Microgateway.

1. Create a license.yaml file, which has the following content:
```
---
config:
  generic:
    license: |
      -----BEGIN LICENSE-----
      eJxFkEnTokgURf+LWzsCEBCpiFowKoMg8KUIZS8YUoZUEkgmqaj/XnYvqpbv
      [...]
      bHy/N5tf//76DY17EVk=
      -----END LICENSE-----
      -- Airlock WAF --
      Owner                        virtinc.com
      Environment                  Productive
      Trial                        on
      Deployment Form              microgateway
      Platform Restriction         no
      Number of Back-end Hosts     99
      Number of CPUs               12
      Number of Sessions           100
      Policy Enforcement           on
      ICAP                         on
      Kerberos                     on
      API Gateway                  on
      SSL VPN                      on
      Reporting                    on
      Expiry                       2020-12-31
      ---------------------
```

2. [Create the image pull secret](#credentials-to-pull-image-from-docker-registry) to pull the microgateway image.
3. Deploy the Microgateway with the license.yaml file:
  ```console
  helm upgrade -i microgateway airlock/microgateway -f license.yaml
  ```

:exclamation: Airlock Microgateway will not work without a valid license. To order one, please contact sales@airlock.com.

:information_source: **Note**:<br>
In productive environments, licenses might be deployed and handled in a different lifecycles. In such cases, an existing license want to be used. Further information for such setups are provided in chapter [Secure handling of license and passphrase](#secure-handling-of-license-and-passphrase).

### Override default values
The Airlock Microgateway Helm chart has many parameters and most of them are already equipped with default values (see [Configuration](#configuration)). Depending on the environment, the defaults must be adapted. To override default values, do the following:

* Create a YAML file that contains the values that differ to the default.
* Apply this YAML file with the `-f` parameter.

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
YAML is very strict with indentation. To ensure that the YAML file itself is correct, check it's content with a YAML validator (e.g. [YAML Lint](http://www.yamllint.com/)).

## Dependencies
The Airlock Microgateway Helm chart has the following optional dependencies, which can be enabled for a smooth start.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | redis | 10.6.12 |
| https://ealenn.github.io/charts | echo-server | 0.3.0 |

### Redis
In case that session handling is enabled on Airlock Microgateway, a Redis service needs to be available. The Airlock Microgateway Helm chart has two options:
* To deploy the dependent Redis service, adapt the Helm chart configuration as shown below:
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
      redis_hosts: [ <REDIS-SERVICE>:<PORT> ]
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
The delivered Helm chart comes pre-configured and tested for the dependent Redis service. Adjusting those settings can cause issues.

### Echo-Server
For the first deployment, it could be very useful to have a backend service processing requests. For this purpose the dependent Echo-Server can be deployed by doing the following:
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

## DSL Configuration
The Helm chart provides two different configuration modes for the Microgateway.
Depending on your environment and use case, one of these options may better suit your needs.
* The **simple configuration mode** is designed to get you started quickly. It supports one virtual host and one Backend System. Some of the more advanced Microgateway functions are not supported.
* The **expert configuration mode** supports multiple virtual hosts and backend systems, and all of the advanced Microgatway features.

### Simple DSL Configuration
The simple DSL configuration mode is designed for a quick start with the microgateway. It does not support some of its advanced features.
The simple DSL configuration supports the following use case:
| Virtual Host | Mapping | Backend Service |
|--|--|--|
| VH1 (hostname: virtinc.com) | M1 (entry_path: /) | BE1 |

Restrictions of the Simple DSL configuration mode:
* Only one Virtual Host is configured.
* Only one Mapping is configured.
* Only one backend service is configured.
* Deny rules can only be configured on a global level, for fine-grained control the expert DSL configuration mode is required.
* Allow rules can not be configured.

The example below shows how to adjust the default values that are preconfigured in the simple DSL configuration mode:

**Example:**

  custom-values.yaml
  ```
  config:
    global:
      ip_header:
        trusted_proxies:
          - 10.0.0.0/28
    simple:
      mapping:
        entry_path: /
        operational_mode: integration
        deny_rules:
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

### Expert DSL configuration
The Expert DSL configuration mode offers more flexibility than the [Simple DSL configuration](#simple-dsl-configuration) mode.
It is possible to use all Microgateway configuration options within the 'dsl' configuration parameter.

For a full list of available Microgateway configuration parameters refer to the [Microgateway Documentation](https://docs.airlock.com/microgateway/