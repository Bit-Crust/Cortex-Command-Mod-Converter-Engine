# Cortex Command Mod Converter Engine

Automatically converts mods to the latest version of the Cortex Command Community Project.

# Contributing

## Locally testing your changes

This builds the project and overwrites any older pip version of it:

`py -m build && pip install dist/*.tar.gz`

## Running the tests

The unit tests are executed on the built files, so that's why the `build` command should be ran first:

`py -m build && py -m unittest`

## Updating this project on PyPI

1. Generate distribution archives with `py -m build`
2. Update this package on PyPI with `twine upload dist/*`
