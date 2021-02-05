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
The configmap tests use snapshots to verify correct rendering of the configmap. These snapshots are checked into the repository as reference.

The snapshots are found in: 'charts/microgateway/tests/\__snapshot\__/'.

Updating the snapshots:
```console
$ helm unittest charts/microgateway -u
```

Dont forget to verify the new snapshots manually before checking them in.
