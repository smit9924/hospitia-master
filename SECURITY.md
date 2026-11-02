# Security policy

> **Draft.** This policy is in draft form while the Hospitia repositories are private. The reporting contact below must be filled in before the project is made public.
> <!-- TODO(owner): set the private security contact and decide whether to enable GitHub private vulnerability reporting. -->

This policy covers all three Hospitia repositories: [hospitia-master](https://github.com/smit9924/hospitia-master), [hospitia-frontend](https://github.com/smit9924/hospitia-frontend) and [hospitia-backend](https://github.com/smit9924/hospitia-backend).

## Supported versions

Hospitia is in early development (`0.x`). Security fixes are made on `main` and released in the next version; older versions aren't patched.

| Version | Supported |
|---|---|
| `main` (latest) | Yes |
| Older `0.x` | No |

## Reporting a vulnerability

**Please don't report security vulnerabilities in public issues, pull requests or discussions.**

Report them privately to **[TODO: security contact]**. Include:

- the affected repository, service or page, and the version or commit;
- a description of the vulnerability and its impact;
- steps to reproduce, or a proof of concept, using test data only;
- any suggested fix.

Don't include real user data, passwords, tokens or `.env` contents.

## What happens next

1. We acknowledge your report within **5 working days**.
2. We investigate, confirm the issue and assess its severity, and keep you updated.
3. We fix it on `main`, deploy the fix, and release it with a **Security** entry in the [changelog](CHANGELOG.md).
4. With your permission, we credit you in the changelog entry.

Please give us reasonable time to fix the issue before disclosing it publicly.

## Scope

In scope: the code in the three repositories and the default configuration they ship (sample environment files, dev container, Jenkins and server setup).

Out of scope: vulnerabilities in third-party services and dependencies themselves (report them upstream), deployments that ignore the documented configuration (for example using `ENVIRONMENT=local` or sample passwords in production), and social engineering.

## Hardening guidance for operators

See [Server setup and deployment](https://github.com/smit9924/hospitia-master/blob/main/docs/operations/deployment.md): use `ENVIRONMENT=production`, replace every sample password, use a strong shared `JWT_ENCRYPTION_SECRET_KEY`, enable HTTPS, and keep the Jenkins host restricted.
