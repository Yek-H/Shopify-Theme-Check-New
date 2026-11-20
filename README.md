# Shopify Theme Check New

[![Update Shopify Theme Check Environment](https://github.com/Yek-H/Shopify-Theme-Check-New/actions/workflows/update-theme-check.yml/badge.svg)](https://github.com/Yek-H/Shopify-Theme-Check-New/actions/workflows/update-theme-check.yml)
[![Latest release](https://img.shields.io/github/v/release/Yek-H/Shopify-Theme-Check-New?display_name=tag)](../../releases/latest)

Automated, reproducible Linux x64 builds of the latest stable Shopify Theme Check from the official [Shopify Theme Tools](https://github.com/Shopify/theme-tools) release tag and frozen pnpm lockfile.

Each release includes the compiled Theme Tools environment, its installed dependencies, an exact [Shopify Liquid documentation](https://github.com/Shopify/theme-liquid-docs) snapshot, and a local `theme-check-local` launcher.

[Latest release](../../releases/latest) · [Update workflow](../../actions/workflows/update-theme-check.yml) · [Installer](scripts/install-latest.sh)

## Requirements

- **Platform:** Linux x64.
- **Node.js:** installed separately, using the exact version recorded in the release's `BUILD_METADATA.json`.
- **Installer commands:** `curl`, `jq`, `sha256sum`, `tar`, `node`, and `realpath`.
- **Installation destination:** a new absolute directory whose parent already exists.

> [!NOTE]
> Releases are built on **Ubuntu 24.04**. Node.js is not bundled with the archive. pnpm is used only during the build and is not required on the target machine.

## Installation

Clone the repository and install the latest release into a new directory:

```bash
git clone --depth 1 https://github.com/Yek-H/Shopify-Theme-Check-New.git
cd Shopify-Theme-Check-New
bash scripts/install-latest.sh "$HOME/shopify-theme-tools"
```

The installer:

1. Finds the latest GitHub Release.
2. Downloads the Linux x64 archive and its SHA-256 checksum.
3. Verifies the archive before extraction.
4. Extracts into a temporary directory on the same filesystem.
5. Runs `theme-check-local --version` against the extracted bundle.
6. Moves the completed installation into the requested destination without overwriting an existing directory.

To upgrade, install the new release into another fresh directory.

## Usage

Run Theme Check against an absolute theme path:

```bash
$HOME/shopify-theme-tools/theme-check-local /absolute/path/to/theme
```

Optionally pass a Theme Check configuration as the second path:

```bash
$HOME/shopify-theme-tools/theme-check-local /absolute/path/to/theme /absolute/path/to/config.yml
```

The launcher prints a JSON array of offenses to standard output.

| Exit code | Meaning |
| ---: | --- |
| `0` | No lint errors |
| `1` | One or more lint errors |
| `2` | Invalid invocation or runtime failure |

### Custom checks

Third-party JavaScript checks are disabled by default.

> [!WARNING]
> Enable custom checks only when you trust the theme configuration and its dependencies.

Place `--allow-custom-checks` before the theme path:

```bash
$HOME/shopify-theme-tools/theme-check-local --allow-custom-checks /absolute/path/to/theme
```

## Releases

The latest build is available from [**GitHub Releases**](../../releases/latest).

Each release publishes:

- `Shopify-theme-tools-<version>-linux-x64.tar.gz`
- `Shopify-theme-tools-<version>-linux-x64.tar.gz.sha256`
- `BUILD_METADATA.json`

To verify an archive manually:

```bash
sha256sum -c Shopify-theme-tools-<version>-linux-x64.tar.gz.sha256
```

### Archive contents

```text
theme-tools/
theme-liquid-docs/
theme-check-local
theme-check-local.cjs
BUILD_METADATA.json
```

The launcher resolves Theme Check from the packaged Theme Tools build and uses the bundled Liquid documentation snapshot.

## Automatic updates

The updater monitors:

- **Theme Check / Theme Tools:** the latest stable `@shopify/theme-check-node` version published to npm.
- **Shopify Liquid documentation:** the latest `main` commit from [Shopify/theme-liquid-docs](https://github.com/Shopify/theme-liquid-docs).

For the selected Theme Tools release, the workflow also reads:

- the required **Node.js** version from the official `dev.yml`;
- the exact **pnpm** version from the upstream `packageManager` field.

The workflow runs every day at **06:00 UTC**. It also runs when `.github/workflows/update-theme-check.yml` or files under `scripts/**` change, and it can be launched manually from **Actions → Update Shopify Theme Check Environment**.

If the same Theme Check version and Liquid documentation revision already have a complete published release, scheduled runs skip the rebuild. Manual runs can use the `force` option to rebuild the same upstream state.

## Build process

The GitHub Actions workflow:

1. Detects the latest stable Theme Check version and latest Liquid documentation commit.
2. Checks whether that exact upstream state already has a complete release.
3. Clones the matching official `Shopify/theme-tools` release tag with recursive submodules.
4. Clones `Shopify/theme-liquid-docs` and verifies its exact commit.
5. Reads the upstream Node.js version from `dev.yml`.
6. Reads and installs the pnpm version declared by Theme Tools.
7. Installs dependencies with `pnpm install --frozen-lockfile`.
8. Builds the complete Theme Tools monorepo.
9. Runs type checking, unit tests, and format validation.
10. Verifies the expected compiled outputs.
11. Runs Theme Check against a minimal smoke-test theme.
12. Packages Theme Tools, dependencies, compiled outputs, Liquid docs, metadata, and the local launcher.
13. Generates the SHA-256 checksum.
14. Tests the final archive without pnpm.
15. Publishes the GitHub Actions artifact and GitHub Release.

Browser downloads are skipped because they are not required for this Theme Check build.

## Reproducibility

Every release records:

- Theme Check version
- Theme Tools source commit
- Liquid docs commit
- Liquid grammar submodule revision
- Node.js version
- pnpm version
- build timestamp
- target OS and architecture

The build starts from the official Theme Tools release tag, the exact Liquid documentation revision, and the frozen upstream lockfile. Dependencies and compiled outputs are generated during the workflow rather than copied from an older installation.

The installer also refuses to overwrite an existing destination, keeping upgrades isolated from previous installations.
