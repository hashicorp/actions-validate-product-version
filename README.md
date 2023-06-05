# actions-validate-product-version

Given an expected version string,
check that the tool emits a matching version string.
The artifact path may refer to a single artifact
or a directory of artifacts to test.
Executables must support a `version` subcommand
and are executed as `$executable version`.

Currently supported artifact types:
   * `foo.zip` -- required to contain executable `foo`, which will be extracted and executed for the test
   * `foo` -- executable to be run as-is
Other non-executable artifacts are skipped.


## Usage

```yaml
jobs:
  test-version-string:
    name: "Test Version String"
    runs-on: ubuntu-latest
    # needs: [ ... ]
    steps:
      - uses: actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab # v3.5.2
      # this example uses set-product-version like many CRT build workflows
      - uses: hashicorp/actions-set-product-version@v1
        name: Set Product Version
        id: set-product-version
      # ... potentially other steps ...
      - name: Test
        uses: hashicorp/actions-validate-product-version@v1
        with:
          expected_version: ${{ needs.set-product-version.outputs.product-version }}
          artifact_path: ./consul
```

### Inputs

| Input              | Description                                            |
| ------------------ | ------------------------------------------------------ |
| `expected_version` | The version the `artifact` expected to declare         |
| `artifact_path`    | The path to the artifact to test (may be a directory)  |


## Development

```bash
act --container-architecture=linux/amd64 --workflows .github/workflows/test.yml
```

### Release Process

1. Commit your changes, open a PR, get it reviewed, and merge to `main`.
1. Checkout the `main` branch and pull the latest changes.
1. Create a new tag for the release, e.g. `v1.0.1` with `git tag v1.0.1 && git push origin v1.0.1`.
1. Update the tag locally, e.g. `git tag -d v1 && git tag v1`
1. Replace the tag upstream, e.g. `git push origin :refs/tags/v1 && git push origin v1`
