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

GitHub Actions validates maintenance pushes and pull requests. A `maintenance-*` tag builds, tests, smoke-checks,
and publishes `ghcr.io/brooksandrew0/job-ops` with that version tag and a commit-specific tag.
Publishing uses the repository-scoped Actions token; no persistent registry credential is needed.
Only trusted tag builds receive package-write permission. Pull requests cannot publish.
The first package defaults to private; review package access deliberately before changing it.
Image digests are recorded in the workflow summary. Builds do not deploy.

The recipe upgrades Debian packages from their configured repositories, so rebuilding the same source can yield
a different image digest. Treat the published digest as the release artifact and pin deployment to that digest.
The initial maintenance line patches Axios, Drizzle, PDF.js, Undici, Tiptap, transitive npm dependencies,
JWCrypto and cryptography. React 18, jsdom 26.1.0 and tooltip 1.2.8 preserve tested application behavior.
Existing compiled upstream documentation assets are retained. The label is a maintenance version, not an upstream release.

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

To verify registry visibility and resolve an existing release digest, dispatch the Maintenance build workflow with
operation `verify-image` and its image tag. This read-only job uses package-read permission and asserts private visibility;
it does not build, publish or deploy. It avoids requiring package access on the deployment host.
