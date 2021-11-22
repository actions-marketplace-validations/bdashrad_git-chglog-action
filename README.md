# Generate changelog with git-chglog

Github Action for creating a CHANGELOG.md file based on semver and conventional commits.

## Usage
### Pre-requisites
Create a workflow .yml file in your repositories .github/workflows directory. An example workflow is available below. For more information, reference the GitHub Help Documentation for Creating a workflow file.

Further more you need to have [git-chlog](https://github.com/git-chglog/git-chglog) configured and have the configuration added to your git repository.

### Inputs
 - `next_version`: Next version number
 - `config_dir`: git-chglog configuration directory. Default: `.chglog`
 - `filename`: Filename to write the changelog to. Default: `CHANGELOG.md`
 - `git_chglog_version`: git-chglog version. Default `v0.15.0`
 - `tag`: Optional, Generate changelog only for this tag.

### Outputs
 - `changelog`: Changelog content if no `filename` input is empty

### Example workflow - upload a release asset
On every `push` to `master` generate a CHANGELOG.md file.

```yaml
---
name: Create changelog
on: 
  push:
    branches:
      - master
      - main
  pull_request:
    branches:
      - master
      - main

jobs:
  generate_changelog:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Generate changelog
        id: gen_changelog
        uses: bdashrad/git-chglog-action@v2.0.3
        with:
          next_version: "1.0.0"
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/bdashrad/git-chglog-action/tags). 

## Authors

- **Steffen F. Qvistgaard** - *Initial work* - [ssoerensen](https://github.com/ssoerensen)
- **Brad Clark** [bdashrad](https://github.com/bdashrad)

See also the list of [contributors](https://github.com/bdashrad/git-chglog-action/contributors) who participated in this project.
