# Change Log
## 0.7

### Enhancements
- Update to Microgateway 2.0.0.

### Breaking Changes
#### Helm Chart Configuration

- Advanced and Simple DSL Configuration are not supported anymore. Configurations using Advanced or Simple DSL Mode will have to migrate to the standard Microgateway DSL configuration. Please refer to the [Microgateway Documentation](https://docs.airlock.com/microgateway/2.0) for further information.
- Helm Chart parameter 'config.generic.env' has been renamed to 'config.generic.configEnv'

#### Breaking Changes in the Microgateway DSL

For a complete reference of the Microgateway DLS, please refer to https://docs.airlock.com/microgateway/2.0.

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
