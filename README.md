# Shopify Theme Check New

GitHub Actions builds the latest stable Shopify Theme Check from its official tag and frozen pnpm lockfile, with a pinned Liquid documentation snapshot per release. Builds run daily and can be started from Actions.

Download the Linux x64 archive from [Releases](../../releases) or run `bash scripts/install-latest.sh /absolute/path/to/new-directory` after cloning this repository. The parent directory must exist. Install upgrades into a fresh directory. Install Node.js separately, using the version listed in the release’s BUILD_METADATA.json. The workflow reads Node.js from upstream dev.yml and pnpm from upstream package.json. pnpm is used only during the build.

Run `theme-check-local /absolute/path/to/theme` from the installed bundle. It outputs a JSON array and exits with 1 for lint errors or 2 for invocation/runtime errors. Third-party JavaScript checks are skipped by default. Use `--allow-custom-checks` before the theme path only when you trust the theme configuration and its dependencies.
