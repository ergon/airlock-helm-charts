# Developer Notes
## Unit Testing
We use the [Helm Unit Test Plugin](https://github.com/quintush/helm-unittest) for unit testing.

### Installation
The unittest plugin needs to be installed with the following command:
```console
$ helm plugin install https://github.com/quintush/helm-unittest
```

### Run unit tests
Invoke from toplevel directory of this repository:
```console
$ helm unittest charts/microgateway
```
### Working with snapshots
The ConfigMap tests use snapshots to verify correct rendering of the ConfigMap. These snapshots are checked into the repository as reference.

The snapshots are found in: 'charts/microgateway/tests/\__snapshot\__/'.

Updating the snapshots:
```console
$ helm unittest charts/microgateway -u
```

Don't forget to verify the new snapshots manually before checking them in.

## Deployment Smoketest
The following example shows how to run a smoke test against a microgateway deployment.
```
helm test <deployment_name>
```
The default URL for the test is '/'. Overwrite the test URL with the parameter 'test_request'.
```
test_request: /myapp/login
```

## Readme Maintenance
Changes in the README.md will be overwritten in the github ci workflow. The ci workflow generates this file using [helm-docs](https://github.com/norwoodj/helm-docs) from the README.md.gotmpl and from the documentation in values.yaml.

Readme changes therefore have to be done in the template file 'README.md.gotempl'.

### Testing Readme Generation
The README.md can be generated using the command `make` in the root directory of this repository.
It uses a [helm-docs docker image](https://hub.docker.com/r/jnorwood/helm-docs) to create the README.md.
