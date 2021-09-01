# Change Log
## 2.2.0

### Enhancements
- An existing ConfigMap containing the DSL file can be mounted into the Microgateway pod using the parameter `config.dslConfigMap`. 

## 2.1.0

### Enhancements
- Expose metrics port in the Microgateway Pod
- Parameters for configuration of Deployment and Pod annotations

## 2.0.0

### Enhancements
- Update to Microgateway 2.1.0.
- Support for Microgateway Community Edition

### Breaking Changes
#### Helm Chart Configuration
It is now possible to configure the encryption passphrase and the Microgateway license in different secrets. Secret names have to be specified for both secrets individually. You can still configure the same pre-existing secret as in previous chart versions, but it needs to be referenced for both the password and the license. If you do not configure license information, no license will be mounted and the Microgateway will run as community edition. 

Required changes:
- To create a license secret with the Helm chart:
  - config.license -> config.license.key
- To mount an existing license secret:
  - config.license.useExistingSecret: true
  - config.existingSecret -> config.license.secretName
- To mount an existing passphrase secret:
  - config.exsistingSecret -> config.passphrase.secretName. 
  - config.passphrase.useExistingSecret: true.
- To create a passphrase secret:
  - config.passphrase -> config.passphrase.value. 

## 1.0.0

### Enhancements
- Update to Microgateway 2.0.0.

### Breaking Changes
#### Helm Chart Configuration

- Advanced and Simple DSL Configuration are not supported anymore. Configurations using Advanced or Simple DSL Mode will have to migrate to the standard Microgateway DSL configuration. Please refer to the [Microgateway Documentation](https://docs.airlock.com/microgateway/2.0) for further information.
- DSL Configuration chart parameter 'config.expert.dsl' has been renamed to 'config.dsl'.
- Parameters 'config.generic.\*' have been renamed to 'config.\*'. Example: 'config.generic.passphrase' has been renamed to 'config.passphrase'.
- Helm Chart parameter 'config.generic.env' has been renamed to 'config.env.runtime'. For environment variables used in DSL variable substitution, use 'config.env.configbuilder'.
- Helm Chart parameter 'image.repository' has been renamed to 'image.repository.runtime'. If you use a custom value for the 
  runtime image, you will probably also need a custom value for the configbuilder repository: 'image.repository.configbuilder'.
- The service name for the echo service has been changed from 'backend-service' to 'backend' to match the microgateway default value. The echo service name can be configured using 'echo-server.fullnameOverride'.
- Secrets for the license and the passphrase are now mounted to the default locations '/secret/license' and '/secret/passphrase' instead of '/secret/config/\*'. Explicit references to the former location of these secrets have to be removed from the DSL.
- Ingress configuration: The helm chart uses ingress API version networking.k8s.io/v1 now. For k8s clusters with version 1.19 or higher, `ingress.servicePortNumber` or `ingress.servicePortName` have to be used instead of `ingress.targetPort`. `ingress.servicePortNumber` takes precedence if both are specified.

#### Breaking Changes in the Microgateway DSL

For a complete reference of the Microgateway DSL, please refer to https://docs.airlock.com/microgateway/2.0.

- The entry_path for a mapping is now defined in a nested value element
```
          mappings:
            - name: webapp
              entry_path:
                value: /
```
- Backends are no longer defined  as child of an app. Backends are now contained in a mapping and may define multiple backend hosts. The hostname has been renamed to host.

```
            mappings:  
              - backend:
                  hosts:
                    - protocol: https
                      name: custom-backend-service
                      port: 8443
```

- The parameter base_template_file is not supported anymore. Use the expert settings on global, virtual host, mapping or backend level to migrate settings from the base_template_file that can not be configured using the Microgateway DSL.
- 'apps.mappings.deny_rules' have been renamed to 'apps.mappings.deny_rule_groups'.
