# Shopify Theme Check New

[![Update Shopify Theme Check Environment](https://github.com/Yek-H/Shopify-Theme-Check-New/actions/workflows/update-theme-check.yml/badge.svg)](https://github.com/Yek-H/Shopify-Theme-Check-New/actions/workflows/update-theme-check.yml)
[![Latest release](https://img.shields.io/github/v/release/Yek-H/Shopify-Theme-Check-New?display_name=tag)](../../releases/latest)

Automated, reproducible builds of the latest stable Shopify Theme Check from the official [Shopify Theme Tools](https://github.com/Shopify/theme-tools) release tag and frozen pnpm lockfile.

Each release bundles Theme Tools, its installed dependencies, compiled outputs, an exact snapshot of the [Shopify Liquid documentation](https://github.com/Shopify/theme-liquid-docs), and a local Theme Check launcher. Node.js is intentionally installed separately on the target machine.

## Download

The latest build is always available from [**Releases**](../../releases/latest).

Each release contains:

- `Shopify-theme-tools-<version>-linux-x64.tar.gz`
- a corresponding SHA-256 checksum file
- `BUILD_METADATA.json`

> [!NOTE]
> Releases target **Linux x64** and are built on **Ubuntu 24.04**. The required Node.js version follows the official Theme Tools `dev.yml` for that release and is recorded in `BUILD_METADATA.json`.

## Install

Install the Node.js version listed in the release's `BUILD_METADATA.json` before using the bundle or installer.

After cloning this repository, install the latest release to a new absolute directory:

```bash
bash scripts/install-latest.sh /absolute/path/to/new-directory
```

The parent directory must already exist, and the destination itself must not exist. The installer verifies the release checksum, extracts into a temporary directory on the same filesystem, validates the bundled launcher, and then moves the completed installation into place without overwriting an existing directory.

Then run Theme Check:

```bash
/absolute/path/to/new-directory/theme-check-local /absolute/path/to/theme
```

An optional Theme Check configuration can be passed as the second path:

```bash
/absolute/path/to/new-directory/theme-check-local /absolute/path/to/theme /absolute/path/to/config.yml
```

The launcher outputs a JSON array of offenses.

- Exit code `0`: no lint errors.
- Exit code `1`: one or more lint errors.
- Exit code `2`: invalid invocation or runtime failure.

Third-party JavaScript checks are skipped by default. Enable them only for trusted theme configurations and dependencies:

```bash
/absolute/path/to/new-directory/theme-check-local --allow-custom-checks /absolute/path/to/theme
```

The `--allow-custom-checks` option must appear before the theme path.

## What it tracks

The updater monitors two independent upstream sources:

- **Theme Check / Theme Tools:** the latest stable `@shopify/theme-check-node` version published to npm.
- **Shopify Liquid documentation:** the latest `main` commit from [Shopify/theme-liquid-docs](https://github.com/Shopify/theme-liquid-docs).

For each Theme Tools release, the build also reads:

- **Node.js:** the version declared by the official Theme Tools `dev.yml`.
- **pnpm:** the exact version declared by Theme Tools' `packageManager` field.

A new release is produced only when the detected Theme Check version and Liquid documentation state have not already been published, unless a manual run is forced.

## Automatic updates

The workflow runs every day at **06:00 UTC** and can also be launched manually from **Actions → Update Shopify Theme Check Environment**.

Changes pushed to `.github/workflows/update-theme-check.yml` or `scripts/**` also run the updater. If the detected upstream state is already published, the workflow exits without rebuilding it.

Manual runs can use the `force` option to rebuild even when the same upstream state already has a release.

## Build process

The GitHub Actions workflow:

1. Detects the latest stable Theme Check version and latest Shopify Liquid documentation commit.
2. Checks whether the exact Theme Check + Liquid docs state already has a complete published release.
3. Checks out the matching official `Shopify/theme-tools` release tag with recursive submodules.
4. Clones `Shopify/theme-liquid-docs` and verifies that its commit exactly matches the detected revision.
5. Reads the required Node.js version from Theme Tools' own `dev.yml`.
6. Reads and installs the pnpm version declared by Theme Tools' `packageManager` field.
7. Installs dependencies with `pnpm install --frozen-lockfile`.
8. Builds the complete Theme Tools monorepo.
9. Runs type checking, unit tests, and format validation.
10. Verifies expected compiled Theme Check and VS Code extension outputs.
11. Runs a Theme Check smoke test against a minimal Shopify theme.
12. Packages Theme Tools, its installed dependencies, compiled outputs, the exact Liquid documentation snapshot, and the local launcher.
13. Generates `BUILD_METADATA.json`, creates a SHA-256 checksum, and builds the Linux x64 archive.
14. Tests the final archive without pnpm to verify that the packaged launcher works independently of the build toolchain.
15. Publishes both a GitHub Actions artifact and a permanent GitHub Release.

Browser downloads are skipped because they are not required for the Theme Check build. pnpm is required only during compilation; the installed bundle requires Node.js but does not require pnpm.

## Release contents

The archive contains:

```text
theme-tools/
theme-liquid-docs/
theme-check-local
theme-check-local.cjs
BUILD_METADATA.json
```

The bundled `theme-check-local` launcher resolves Theme Check from the packaged Theme Tools build and uses the bundled Liquid documentation snapshot.

## Reproducibility

Every release records:

- Theme Check version
- Theme Tools source commit
- Liquid docs commit
- Liquid grammar submodule revision
- Node.js version
- pnpm version
- build timestamp
- target OS/architecture

The build starts from the official Theme Tools release tag, exact Liquid documentation revision, and frozen upstream lockfile. Dependencies and compiled outputs are generated during the workflow rather than copied from an older installation.

The installation script also refuses to overwrite an existing destination, so upgrades are installed into a fresh directory rather than modifying a previous bundle in place.
