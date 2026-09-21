# Maintenance fork

This branch carries a small, tested maintenance delta over upstream JobOps v0.13.1
(`b8412b14789ead6347fc3d82fdeb29096227a159`). Upstream remains the source of new product releases.

Application manifests, the lockfile, PDF.js compatibility fix and regression coverage live directly in this repository.
The build recipe is `maintenance/Dockerfile.security`; the original upstream Dockerfile is retained for reference.
Use this maintenance recipe for maintenance images.

## Build and verify

Commit the intended source first. From the repository root:

```sh
./maintenance/build.sh /tmp/jobops-build-UNIQUE
./maintenance/runtime-check.sh
```

The build uses the committed HEAD, Node 22 from the pinned upstream image and npm 12.0.2.
It runs every upstream CI-parity check, including the complete test suite, before constructing the production image.
Runtime checks create disposable data without published ports and exercise setup/login/API access, Firefox,
Python dependencies, JWT signing and PDF generation. Local model integration requires a separate deployment-stage check.
No application credentials or production data belong in this fork.

## Releases

This public fork validates builds only. Private image publication belongs to the owner's private infrastructure repository,
which associates images with the private repository, runs checks and verifies package visibility. Do not publish packages
from this public fork: workflow-created packages can inherit the public repository's visibility.

The application commit and image digest must be recorded together. Builds do not deploy. Debian package repositories can
change between builds, so always pin the published digest rather than assuming a tag identifies identical bytes forever.

## Upstream updates

Keep the fork's `main` as an upstream reference. Work on `maintenance`; do not force maintenance commits onto upstream history.
For each upstream release, review release notes/migrations, apply the smallest still-needed changes, remove superseded
patches, run all checks and review dependency advisories. Submit generally useful fixes separately when appropriate.
Do not auto-merge dependency updates or deploy successful builds automatically.

Deployment configuration, approved image digests, host-specific settings, backups, rollback and operating records
remain in the owner's private `personal-infra` repository. This fork contains only application and build material.

Known residuals from the initial security review: production `stream-json` 1.9.1 has a moderate filter-path DoS advisory;
Crawlee uses the unaffected StreamArray API. Development-only older esbuild versions match a development-server advisory.
These must be reassessed on future updates. This recipe is not a claim that every OS package or bundled tool is vulnerability-free.
