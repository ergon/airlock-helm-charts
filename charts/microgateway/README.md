# Airlock Microgateway

Airlock Microgateway helps you to protect your services and APIs from unauthorized or malicious access with little effort. It is a lightweight Web Application Firewall (WAF) and API security gateway designed specifically for use in container environments.

The current chart version is: 3.1.13

## Table of contents
* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Installing the Chart](#installing-the-chart)
* [Getting started](#getting-started)
* [Parameters](#parameters)
* [Dependencies](#dependencies)
* [DSL Configuration](#dsl-configuration)
* [Environment Variables](#environment-variables)
* [Extra Volumes](#extra-volumes)
* [Readiness and Liveness Probes](#readiness-and-liveness-probes)
* [External connectivity](#external-connectivity)
  * [Kubernetes Ingress](#kubernetes-ingress)
  * [Openshift Route](#openshift-route)
* [Security](#security)
  * [Store sensitive information in secrets](#store-sensitive-information-in-secrets)
  * [Service Account](#service-account)
* [Configuring a License](#configuring-a-license)

## Introduction
This Helm chart bootstraps [Airlock Microgateway](https://www.airlock.com) on a [Kubernetes](https://kubernetes.io) or [Openshift](https://www.openshift.com) cluster using the [Helm](https://helm.sh) package manager. It provisions an Airlock Microgateway Pod with a default configuration that can be adjusted to customer needs. For more details about the configuration options, see chapter [Helm Configuration](#dsl-configuration).

## Prerequisites
* The Airlock Microgateway image
* Airlock Microgateway is available as premium and community edition. <br>
  Without a valid license, Airlock Microgateway works as community edition with limited functionality. <br>
  For further information refer to [Microgateway Documentation](https://docs.airlock.com/microgateway/3.4/). <br>
  If you want to try the premium features, [request a license key](https://airlock.com/microgateway-premium) and [configure it](#configuring-a-license).
* Redis service for session handling (see chapter [Dependencies](#dependencies))

## Installing the Chart
To configure the chart repository:

  ```console
  helm repo add airlock https://ergon.github.io/airlock-helm-charts/
  ```

To install the Airlock Microgateway community edition with the release name `microgateway`:

  ```console
  helm upgrade -i microgateway airlock/microgateway
  ```
Consult chapter [Configure a valid license](#configuring-a-license) for further instructions on how to install a license for the Airlock Microgateway premium edition.

To uninstall the chart with the release name `microgateway`:

  ```console
  helm uninstall microgateway
  ```

## Getting started
This chapter provides a simple example to help you get the Airlock Microgateway running in no time.

**Example:**

  custom-values.yaml
  ```
  config:
    dsl:
      session:
        redis_hosts: [redis-master]
      log:
        level: info
      remote_ip:
        header: X-Forwarded-For
        internal_proxies:
          - 10.0.0.0/28

      apps:
        - mappings:
            - session_handling: enforce_session
              deny_rule_groups:
                - level: strict

  redis:
    enabled: true
  echo-server:
    enabled: true
  ingress:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      kubernetes.io/ingress.class: nginx
    hosts:
        - micro-echo
  ```

 Apply the Helm chart configuration file with the `-f` parameter.
  ```console
  helm upgrade -i microgateway airlock/microgateway -f custom-values.yaml
  ```

## Parameters
The following table lists configuration parameters of the Airlock Microgateway chart and the default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | string | `nil` | Assign custom [affinity rules](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) (multiline string). |
| annotations | object | `{}` | Additional annotations for the Microgateway Deployment |
| commonLabels | object | `{}` | Labels to add to all resources. |
| config.dsl | object | `{}` | [DSL configuration](#dsl-configuration) Template rendering fails if `config.dslConfigMap` and `config.dsl` are specified. |
| config.dslConfigMap | string | "" | Name of the ConfigMap containing the Microgateway DSL configuration file. <br> The DSL is expected in a data entry called `config.yaml`. <br> <br> Template rendering fails if `config.dslConfigMap` and `config.dsl` are specified. |
| config.env | object | "See `config.env.*`" | [DSL Environment Variables](#dsl-environment-variables) |
| config.env.configbuilder | list | `[]` | [DSL Environment Variables](#dsl-environment-variables) |
| config.env.runtime | list | `[]` | [Runtime Environment Variables](#runtime-environment-variables) |
| config.jwks | object | "see `config.jwks.*`" | [Secrets for JWKS services](#jwks-service-secrets) |
| config.jwks.clientCertificateSecretName | string | "" | Name of an existing secret containing:<br><br> Certificate: `client.crt`<br> Private key: `client.key`<br> CA Certificate: `client-ca.crt` <br> The files will be available in '/secret/auth/jwks/tls/client/'. |
| config.jwks.localJWKSSecretName | string | "" | Name of an existing secret with a jwks json file. The secret must contain:<br><br> JWKS File: `jwks.json`<br><br> The JWKS file will be available in '/secret/jwks/jwks.json' for reference in local JWKS service configurations in the DSL. |
| config.jwks.serverCASecretName | string | "" | Name of an existing secret containing:<br><br> Server CA Certificate: `server-validation.crt`<br> The files will be available in '/secret/auth/jwks/tls/server/'. |
| config.license | object | "" | Creates or mounts a secret with an Airlock Microgateway license. <br> If 'useExistingSecret: false' and no 'license.key' is given, the Airlock Microgateway runs in community mode. <br> If 'useExistingSecret: false' and the 'license.key' is given, a secret with the license will be created and mounted. <br> If 'useExistingSecret: true' and 'license.secretName' has a name, the referenced secret will be mounted. <br> If 'useExistingSecret: true' and 'license.key' is given, the license defined in 'secretName' will be used. |
| config.license.key | string | "" | The Airlock Microgateway license key which will be stored and used in a secret. |
| config.license.secretName | string | "" | Name of an existing secret containing: <br> <br> license: `license` |
| config.license.useExistingSecret | bool | `false` | Specifies whether a pre-existing secret should be mounted. |
| config.passphrase | object | "" | Passphrase used for encryption. <br> If 'useExistingSecret: false' and no 'passphrase.value' is given, a random value will be created and stored in a secret. <br> If 'useExistingSecret: false' and a 'passphrase.value' is given, a secret with the passphrase will be created and mounted. <br> If 'useExistingSecret: true' and no 'passphrase.secretName' has a name, the referenced secret will be mounted. <br> If 'useExistingSecret: true' and 'passphrase.value' is given, the passphrase defined in 'secretName' will be used. |
| config.passphrase.secretName | string | "" | Name of an existing secret containing: <br> <br> passphrase: `passphrase` |
| config.passphrase.useExistingSecret | bool | `false` | Specifies whether a pre-existing secret should be mounted. |
| config.passphrase.value | string | "" | The passhprase which will be stored and used in a secret. |
| config.tlsSecretName | string | "" | Name of an existing secret containing:<br><br> _Virtual Host:_<br> Certificate: `frontend-server.crt`<br> Private key: `frontend-server.key`<br> CA: `frontend-server-ca.crt` <br> :exclamation: Update `route.tls.destinationCACertificate` accordingly.<br><br> _Backend:_<br> Certificate: `backend-client.crt`<br> Private key: `backend-client.key`<br> CA: `backend-server-validation-ca.crt` |
| echo-server | object | See `echo-server.*`: | Pre-configured [Echo-Server](#echo-server). |
| echo-server.enabled | bool | `false` | Deploy pre-configured [Echo-Server](#echo-server). |
| extraVolumeMounts | list | `[]` | Add additional volume mounts. |
| extraVolumes | list | `[]` | Add additional volumes. [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) |
| fullnameOverride | string | `""` | Provide a name to substitute for the full names of resources. |
| hpa | object | See `hpa.*`: | [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to scale <br> Microgateway based on Memory and CPU consumption.<br><br> :exclamation: Check [API versioning](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#api-versioning) when using this Beta feature. |
| hpa.enabled | bool | `false` | Deploy a horizontal pod autoscaler. |
| hpa.maxReplicas | int | `10` | Maximum number of Microgateway replicas. |
| hpa.minReplicas | int | `1` | Minimum number of Microgateway replicas. |
| hpa.resource.cpu | int | `50` | Average Microgateway CPU consumption in percentage to scale up/down.<br><br> :exclamation: Please set the resource request parameter `resources.cpu` to a value reflecting your actual resource needs if you use autoscaling based on cpu consumption. Otherwise autoscaling will not work as expected. |
| hpa.resource.memory | string | `"3Gi"` | Average Microgateway Memory consumption to scale up/down.<br><br> :exclamation: Update this setting depending on your `resources.limits.memory` setting. |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy (`Always`, `IfNotPresent`, `Never`) |
| image.repository | object | "See `image.repository.*`" | Image repositories for the Airlock Microgateway. |
| image.repository.configbuilder | string | `"docker.io/ergon/airlock-microgateway-configbuilder"` | Image repository for the Airlock Microgateway configbuilder image |
| image.repository.runtime | string | `"docker.io/ergon/airlock-microgateway"` | Image repository for the Airlock Microgateway runtime image |
| image.tag | string | `"3.4.13"` | Image tag for microgateway and configbuilder image |
| imageCredentials | object | See `imageCredentials.*`: | Creates a imagePullSecret with the provided values. |
| imageCredentials.enabled | bool | `false` | Enable the imagePullSecret creation. |
| imageCredentials.password | string | `""` | imagePullSecret password/Token |
| imageCredentials.registry | string | `"https://index.docker.io/v1/"` | imagePullSecret registry |
| imageCredentials.username | string | `""` | imagePullSecret username |
| imagePullSecrets | list | `[]` | Reference to one or more secrets to use when pulling images. |
| ingress | object | See `ingress.*`: | [Kubernetes Ingress](#kubernetes-ingress) |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/rewrite-target":"/"}` | Annotations to set on the ingress. |
| ingress.enabled | bool | `false` | Create an ingress object. |
| ingress.hosts | list | `[]` | List of ingress hosts. A rule will be created for every host. Use an empty list to create a wildcard '*' rule. |
| ingress.labels | object | `{}` | Additional labels to add on the Microgateway ingress. |
| ingress.path | string | `"/"` | Path for the ingress. |
| ingress.pathType | string | `"Prefix"` | pathType of the ingress path (used with ingress v1 and higher) |
| ingress.servicePortName | string | `"http"` | Name of the service target port with ingress API version networking.k8s.io/v1 (Kubernetes version >= 1.19) `ingress.servicePortNumber` takes precedence over `ingress.servicePortName` if both are specified. Possible Values are: `http`, `https`. |
| ingress.servicePortNumber | string | `nil` | Number of the service target port with ingress API version networking.k8s.io/v1 (Kubernetes version >= 1.19) `ingress.servicePortNumber` takes precedence over `ingress.servicePortName` if both are specified. |
| ingress.targetPort | string | `"http"` | Target port of the service with ingress API version networking.k8s.io/v1beta1 (Kubernetes version < 1.19) Possible values are: `http`, `https` or `<number>`. |
| ingress.tls | list | `[]` | [Ingress TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration. |
| initResources | object | See `initResources.*` | Resource requests/limits for the init container. <br> [Init container resource limits](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#resources) |
| initResources.limits | object | See `initResources.limits.*` | Resource limits for the init container. |
| initResources.limits.cpu | string | `"1000m"` | CPU limit for the init container. |
| initResources.limits.memory | string | `"512Mi"` | Memory limit for the init container. |
| initResources.requests | object | See `initResources.requests.*` | Resource requests for the init container. |
| initResources.requests.cpu | string | `"30m"` | CPU request for the init container. |
| initResources.requests.memory | string | `"256Mi"` | Memory request for the init container. |
| livenessProbe.enabled | bool | `true` | Enable liveness probes. |
| livenessProbe.failureThreshold | int | `9` | After how many subsequent failures the pod gets restarted. |
| livenessProbe.initialDelaySeconds | int | `90` | Initial delay in seconds. |
| livenessProbe.timeoutSeconds | int | `5` | Timeout of liveness probes, should roughly reflect allowed timeouts from clients. |
| nameOverride | string | `""` | Provide a name in place of `microgateway`. |
| nodeSelector | object | `{}` | Define which nodes the pods are scheduled on. |
| podAnnotations | object | `{}` | Additional annotations for the Microgateway Pod |
| podSecurityContext | object | `{}` | [Security context for the pods](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod). |
| readinessProbe.enabled | bool | `true` | Enable readiness probes. |
| readinessProbe.failureThreshold | int | `3` | After how many tries the pod stops receiving traffic. |
| readinessProbe.initialDelaySeconds | int | `10` | Initial delay in seconds. |
| redis | object | See `redis.*`: | Pre-configured [Redis](#redis) service. |
| redis.enabled | bool | `false` | Deploy pre-configured [Redis](#redis). |
| replicaCount | int | `1` | Desired number of Microgateway pods. |
| resources | object | See `resources.*` | Resource requests/limits for the runtime container. <br> [Resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) <br> [Configure Quality of Service for Pods](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/) |
| resources.limits | object | See `resources.limits.*` | Resource limits for the runtime container. |
| resources.limits.memory | string | `"4048Mi"` | Memory limit for the runtime container. |
| resources.requests | object | See `resources.requests.*` | Resource requests for the Microgateway runtime container. These values most like have to be adjusted depending on specific load and usage profiles. <br> Please consult [Microgateway resource requirements](https://docs.airlock.com/microgateway/3.4/#data/1581621320714.html) for some ideas about actual Microgateway resource requirements. |
| resources.requests.cpu | string | `"30m"` | CPU request for the runtime container. |
| resources.requests.memory | string | `"256Mi"` | Memory request for the runtime container. |
| route | object | See `route.*`: | [Openshift Route](#openshift-route) |
| route.annotations | object | `{}` | Annotations to set on the route. |
| route.enabled | bool | `false` | Create a route object. |
| route.hosts | list | `["virtinc.com"]` | List of host names. <br> A route will be created for every host name listed. No route will be created if no hosts are specified. Use an empty string to generate a route without hostname. |
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
| service.externalTrafficPolicy | string | `Local` if `service.type=LoadBalancer` | [externalTrafficPolicy](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip) |
| service.labels | object | `{}` | Additional labels to add on the service. |
| service.loadBalancerIP | string | "" if `service.type=LoadBalancer` | [loadBalancerIP](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) |
| service.port | int | `80` | Service port |
| service.tlsPort | int | `443` | Service TLS port |
| service.type | string | `"ClusterIP"` | [Service type](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) |
| serviceAccount | object | "See `serviceAccount.*`" | Specifies the service account under which the microgateway will run. A dedicated service account is created and used by default. <br><br> If `serviceAccount.create=true` and no `serviceAccount.name` is given, a name is generated using the fullname template. <br><br> If `serviceAccount.create=false` and no `serviceAccount.name` is given, the microgateway runs under the default service account. |
| serviceAccount.annotations | object | `{}` | Annotations to set on the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.labels | object | `{}` | Additional labels added on the service account. |
| serviceAccount.name | string | `nil` | The name of the ServiceAccount to use. <br><br> |
| test_request | string | `"/"` | Request that will be used as a smoketest when 'helm test' is invoked. |
| tolerations | list | `[]` | Tolerations for use with node [taints](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/). |

## Dependencies
The Airlock Microgateway Helm chart has the following optional dependencies, which can be enabled for a smooth start.

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | redis | 17.4.3 |
| https://ealenn.github.io/charts | echo-server | 0.5.0 |

### Redis
In case that session handling is enabled on Airlock Microgateway, a Redis service needs to be available.

The following example shows how to deploy a redis service with the Helm chart and reference it in the Microgateway DSL:
  ```
  redis:
    enabled: true
  config:
    dsl:
      session:
        redis_hosts: [redis-master]
  ```

**Possible settings**:<br>
Please refer to the [Redis Helm chart](https://hub.helm.sh/charts/bitnami/redis) to see all possible parameters of the Redis Helm chart.

**Adjustments of the default settings**:<br>
The delivered Helm chart comes pre-configured and tested for the dependent Redis service. Adjusting those settings can cause issues.

### Echo-Server
For the first deployment, it could be very useful to have a backend service processing requests. For this purpose the dependent Echo-Server can be deployed by doing the following:
  ```
  echo-server:
    enabled: true
  ```

**Possible settings**:<br>
Please refer to the [Echo-Server Helm chart](https://artifacthub.io/packages/helm/ealenn/echo-server) to see all possible parameters of the Echo-Server Helm chart.

## DSL Configuration
The Microgateway DSL configuration can be provided in 2 different ways:
- within the Helm Chart 'dsl' configuration parameter
- in an existing ConfigMap mounted into the Microgatway pod

**Changing the DSL configuration in a running system**:<br>
The microgateway does not detect DSL changes at runtime. If the DSL configuration is managed by the Helm Chart, a deployment rollout is triggered automatically after a DSL change.
If the DSL is mounted from a volume not managed by the Helm Chart, a manual restart is required.

For a full list of available Microgateway configuration parameters refer to the [Microgateway Documentation](https://docs.airlock.com/microgateway/3.4/)

**Example DSL Parameter:**

  ```
  config:
    dsl:
      session:
        redis_hosts: [redis-master]
      log:
        level: info
      remote_ip:
        header: X-Forwarded-For
        internal_proxies:
          - 10.0.0.0/28

      apps:
        - virtual_host:
            hostname: virtinc.com
          mappings:
            - name: webapp
              entry_path:
                value: /
              operational_mode: integration
              session_handling: enforce_session
            - name: api
              entry_path:
                value: /api/
              session_handling: ignore_session
              openapi:
                spec_file: /config/virtinc_api_openapi.json
              backend:
                hosts:
                  - protocol: https
                    name: custom-backend-service
                    port: 8443

  redis:
    enabled: true

  ```

**Example existing ConfigMap:**

  ```
  config:
    dslConfigMap: microgateway-config

  redis:
    enabled: true

  ```

  microgateway-config.yaml
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: microgateway-config
  data:
    config.yaml: |
      session:
        redis_hosts: [redis-master]
      log:
        level: info

      ...
      ...
  ```

## Environment Variables
### DSL Environment Variables
Environment variables can be configured with the Helm chart and used within the [DSL Configuration](#dsl-configuration).
The example below illustrates how to configure environment variables in combination with the [DSL configuration](#dsl-configuration).

  ```
  config:
    env:
      configbuilder:
        - name: OPERATIONAL_MODE
          value: integration
        - name: DR_LOG_ONLY
          value: true
    dsl:
      apps:
        - virtual_host:
            hostname: virtinc.com
          mappings:
            - name: webapp
              operational_mode: ${OPERATIONAL_MODE:-production}
              deny_rules:
                log_only: ${DR_LOG_ONLY:-false}
  ```

### Runtime Environment Variables
The Helm chart also allows to specify environment variables for the runtime container.
The following example shows how to set the timezone of the microgateway:

```
config:
  env:
    runtime:
      - name: TZ
        value: Europe/Zurich
```

## Extra Volumes
The Helm chart allows you to define extra volumes which can be used in the Microgateway.
The configuration of such additional volumes could look like this:

```
extraVolumes:
  - name: mapping
    configMap:
      name: mapping-configmap
extraVolumeMounts:
  - name: mapping
    mountPath: /config/template/mapping.xml
    subPath: mapping.xml

config:
  dsl:
    apps:
    - virtual_host:
        hostname: virtinc.com
      mappings:
        - mapping_template_path: /config/template/mapping.xml
```

## Readiness and Liveness Probes
The Helm chart defines default values for readiness and liveness probes. Use the parameters `readinessProbe` and `livenessProbe` to disable probes or set probe parameters according to your requirements.

The following example shows how to increase the initial delays for liveness and readiness probes.

```
readinessProbe:
  initialDelaySeconds: 90
livenessProbe:
  initialDelaySeconds: 120 
```

## External connectivity
The Helm chart can create a Kubernetes Ingress or Openshift Route object to pass external traffic to the Microgateway service.
In case that those objects have to be created with this Helm chart, just follow along with the description and configuration examples.
If there is already an existing Ingress or Route object and the traffic should only be passed to the Microgateway service, the information in the subchapters should provide useful information about how to integrate into the existing environment.

**Kubernetes vs. Openshift**:<br>
This Helm chart can be used for Kubernetes and Openshift. While Kubernetes has "Ingress" and Openshift has "Route", simply enable the feature which fits to the environment (e.g. in Kubernetes `ingress.enabled=true` and in Openshift `route.enabled=true`).

### Kubernetes Ingress
Kubernetes allows using different kinds of Ingress controllers. Our examples are based on the [nginx-ingress](https://kubernetes.github.io/ingress-nginx) controller.

  The example below shows how to install the nginx-ingress-controller with Helm:
  ```console
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update

  helm install nginx ingress-nginx/ingress-nginx
  ```

**Note**:<br>
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
The TLS certificate of the Ingress must be in a secret object which is referred to in the Ingress configuration.
At the time of writing, Ingress supports only the default port 443 for HTTPS and directly assumes it is TLS.
In case that multiple hosts are configured, TLS-SNI is used to distinguish what host the client requested.
For each configured `ingress.tls.host`, an `ingress.hosts` entry must also be created to ensure that the ingress rules are created correctly.

  To receive HTTPS traffic from the outside of the Kubernetes cluster, use the following configuration:
  ```
  ingress:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/backend-protocol: https
    targetPort: https
    tls:
      - secretName: virtinc-tls-secret
        hosts:
          - virtinc.com
    hosts:
      - virtinc.com
  ```

### Openshift Route
Since the Route controller is already available in an Openshift environment, nothing has to be installed additionally.

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
Openshift has three different TLS termination types that can be used. Edge, re-encrypt and passthrough.
The subchapters provide the required information to configure it, using the Microgateway Helm chart.

##### Route Edge configuration
With the TLS termination type "Edge", HTTPS traffic is terminated on the Openshift Router.
Therefore, a valid certificate for the specified hosts must be applied.

  To setup Edge TLS termination, use the following configuration:
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

##### Route Re-encrypt configuration
With the TLS termination type "Re-encrypt", HTTPS is terminated on the Openshift Router and re-encrypted to the Microgateway service.
Because the default in the Microgateway Helm chart for `route.targetPort` is `https`, traffic inside the Openshift cluster is by default encrypted.
The difference to TLS termination type "Edge" is:
* The Microgateway certificate is validated against `route.tls.destinationCACertificate`.
* It is enforced, that `route.targetPort=https` (Edge would also work with `route.targetPort=http`)

In other words, the entire path of the connection is encrypted and verified, also within the Openshift cluster.

  To setup Re-encrypt TLS termination, use the following configuration:
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
With the TLS termination type "Passthrough", HTTPS traffic is sent directly to the Microgateway, without decrypting it on the route.
Therefore, no certificates need to be configured on the Route and termination takes place in the Microgateway.

  To setup Passthrough TLS termination, use the following configuration:
  ```
  route:
    enabled: true
    path: ""
    hosts:
      - virtinc.com
    tls:
      enabled: true
      termination: passthrough
      destinationCACertificate: ""
  ```

#### Hostnames Generated by Openshift
Openshift assigns an automatically generated hostname to a route if you do not provide one.
You can achieve this by specifying an empty string as hostname.

```
route:
  enabled: true
  path: ""
  hosts:
    - ""
```

## Security
The following subchapters describes how to use and securely deploy the Microgateway.

### Store sensitive information in secrets
Airlock Microgateway uses sensitive information that should be protected accordingly. E.g. in Kubernetes or Openshift environments this information should be stored in secrets.
The following subchapters describe which information should be protected and how this can be achieved.

#### Secure handling of the session store passphrase
The Helm chart either creates a secret for the session store passphrase or uses an existing one and configures the Microgateway to use it. Storing sensitive information in secrets is best practise and also secure. Nevertheless, ensure that these secrets are not stored in Git where too many people have access to it.

##### Using an existing passphrase secret

The example below shows how to create a secret containing the passphrase.
  ```console
  kubectl create secret generic microgateway-passphrase --from-file=passphrase=<passphrase_file>
  ```

Reference the secret in the Helm chart configuration file.
  ```
  config:
    passphrase:
      useExistingSecret: true
      secretName: "microgateway-passphrase"    
  ```

##### Creating secrets with the Helm Chart
The example below shows how to create the passphrase secret using the Helm Chart.

```
config:
  passphrase:
    value: "my-passphrase"
```

#### Credentials to pull image from Docker registry
The Microgateway image is published on our Docker Hub repository. The repository itself is public and the image can be pulled without special permissions.
Nevertheless, Docker has [rate limits](https://www.docker.com/increase-rate-limits) for anonymous users in place. Therefore, it is recommended to use an Docker Hub account to pull the image.
In order to download this image, the Helm chart needs the Docker credentials to authenticate against the Docker registry.
Either an already existing Docker secret is provided (`imagePullSecrets`) during the installation of the Microgateway, or a Kubernetes secret is created with the provided credentials (`imageCredentials`).

  The example below shows how to create a secret with the credentials to download the image from the Docker registry.
  ```console
  kubectl create secret docker-registry docker-secret --docker-username=<username> --docker-password=<access_token>
  ```

  Afterwards use this secret in the Helm chart configuration file.
  ```
  imagePullSecrets:
      - name: "docker-secret"
  ```

  The following example shows how to configure the Helm chart so that a Kubernetes credential is created.
```
imageCredentials:
  enabled: true
  username: <username>
  password: <access_token>
```

#### Certificates for Microgateway
The Microgateway can be configured to use a specific certificate for frontend and/or backend connections. The certificate must be stored in a secret
and passed to the Helm chart to use it.

Used for frontend connection:
* Certificate: `frontend-server.crt`
* Private key: `frontend-server.key`
* CA:          `frontend-server-ca.crt`

In case that [Route Re-encrypt configuration](#route-re-encrypt-configuration) is used, ensure that `route.tls.destinationCACertificate` is updated accordingly.

Used for backend connection:
* Certificate: `backend-client.crt`
* Private key: `backend-client.key`
* CA:          `backend-server-validation-ca.crt`

  The example below shows how to create a secret containing certificates for frontend and backend connections.
  ```console
  kubectl create secret generic microgateway-tls \
                                --from-file=frontend-server.crt=<frontend_cert_file> \
                                --from-file=frontend-server.key=<frontend_key_file> \
                                --from-file=frontend-server-ca.crt=<frontend_ca_file> \
                                --from-file=backend-client.crt=<backend_cert_file> \
                                --from-file=backend-client.key=<backend_key_file> \
                                --from-file=backend-ca.crt=<backend_ca_file>
  ```

  Afterwards use this secret in the Helm chart configuration file.
  ```
  config:
    tlsSecretName: "microgateway-tls"
  ```

#### JWKS Service Secrets
JWKS Services can be configured to provide keys for decryption and signature verification of access tokens.
There are two types of JWKS services:
- Local JWKS Services use a static JWKS that is either provided inline in the DSL or through a secret that is mounted into the Microgateway.
- Remote JWKS Services retrieve JWKS files from a remote service.

##### Configure a local JWKS Service with a secret
Create a secret containing your JWKS file if it does not exist yet:
```console
kubectl create secret generic local-jwks --from-file=jwks.json=<jwks_file>
```

A restart of the Microgateway is required in case of changes in the mounted JWKS secret.

Use the secret in the DSL to create a local JWKS service like this:
```
config:
  jwks:
    localJWKSSecretName: local-jwks
  dsl:
    apps:
        - mappings:
            access_token:
              ... your access token configuration ...
              jwks_providers:
                - jwks-local               
    jwks_providers:
      local:
        - name: jwks-local
          jwks_file:  /secret/jwks/jwks.json
```
Note that the JWKS file has to referenced in JWKS service configuration.

##### Configure local JWKS services using extra volume mounts
Parametrization of the Helm Chart only allows to configure one local JWKS Service. For configuring more than one service,
the parameters `extraVolumes` and `extraVolumeMounts` may be used.
With extra volume mounts, JWKS files can be mounted to a path other than `/secret/jwks/jwks.json`.

See [Extra Volumes](#extra-volumes) for additional information and an example.

##### Configure TLS for Remote JWKS Service with secrets
A client certificate and a server CA certificate may be provided for remote JWKS services.

Client Certificate:
```console
kubectl create secret generic jwks-clientsecret --from-file=client.key=<your private key> --from-file=client.crt=<your public key>
```

Server CA Certificate:
```console
kubectl create secret generic jwks-serversecret --from-file=server-validation.crt=<your server ca certificate>
```

Use these secrets in the DSL to configure Remote JWKS Services:
```
config:
  jwks:
    clientCertificateSecretName: jwks-clientsecret
    serverCASecretName: jwks-serversecret
  dsl:
    apps:
        - mappings:
            access_token:
              ... your access token configuration ...
              jwks_providers:
                - jwks-remote               
    jwks_providers:
      remote:
        - name: jwks-remote
          service_url: <jwks service url>
```

##### Configure TLS for Remote JWKS Service using extra volume mounts
Parametrization of the Helm Chart only allows to configure one set of secrets for remote JWKS Services. For configuring more than one service,
the parameters `extraVolumes` and `extraVolumeMounts` may be used.

See [Extra Volumes](#extra-volumes) for additional information and an example.

### Service Account
The Microgateway runs under a dedicated service account created with the deployment by default.
The following example shows how to use an existing service account instead of having one created in the deployment.
```
serviceAccount:
  create: false
  name: <existing service account>
```

## Configuring a License
### Using an existing license secret:
  ```console
  kubectl create secret generic microgateway-license --from-file=license=<license_file>
  ```

 Reference this secret in the Helm chart configuration file:
  ```
  config:
    license:
      useExistingSecret: true
      secretName: "microgateway-license"     
  ```

### Creating a license secret with the Helm Chart
Create a license secret with the Helm chart:
```
config:
  license:
    key: |
      -----BEGIN LICENSE-----
      <my-license>
      -----END LICENSE-----
```

## Additional Information
- Introduction: [Airlock Microgateway](https://www.airlock.com/microgateway)
- Documentation: [Airlock Microgateway Manual](https://docs.airlock.com/microgateway/3.4/)
- Community Support: [Airlock Community Forum](https://forum.airlock.com)
- Integration Example: [Airlock Minikube Example](https://github.com/ergon/airlock-minikube-example)

## About Ergon
*Airlock* is a registered trademark of [Ergon](https://www.ergon.ch). Ergon is a Swiss leader in leveraging digitalisation to create unique and effective client benefits, from conception to market, the result of which is the international distribution of globally revered products.