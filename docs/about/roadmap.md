# Roadmap

This page describes the direction of the project. It is a plan, not a promise; priorities can change.

## Now: foundations (0.x)

Done or in progress, see the [changelog](../changelog.md):

- Accounts, roles, email verification and password reset.
- Organizations, multi-organization membership and the active organization.
- Room setup: currency units, amenities, room types and rooms.
- Central documentation, agent rules and documentation sync tooling.

## Next

Areas whose services already exist but have no user-facing features yet:

- **Booking:** guests request and book rooms; managers confirm, check in and check out. (Booking service)
- **Payments:** record and track payments for bookings. (Payment service)
- **Dashboards:** occupancy and activity for owners and managers. (Dashboard service; a floor-wise room status chart is being explored on a feature branch.)

## Later

!!! note "TODO"
    Owner to list the planned features, their order, and any target dates. Candidates seen in the code base: metrics endpoints for Prometheus (prepared but disabled in `server-setup/`), HTTPS for all subdomains (configuration prepared but commented out), and more interface languages.

## How to propose something

Open a feature request issue in the repository it belongs to; see [Support](../community/support.md).
