# Vision and mission

This page is for anyone who wants to understand why Hospitia exists and who it serves.

## The problem

Many NGOs, trusts and community organizations run guest houses: rooms offered to pilgrims, volunteers, visiting staff, patients' families or travellers. These guest houses are often managed with registers, spreadsheets and phone calls. That makes it hard to know which rooms are available, which rooms are out of service, who is responsible for a property, and how a property is performing.

Commercial hotel software is usually designed for profit-driven hotels: it is expensive, complex, and assumes a single business rather than an organization that runs several properties with volunteer or rotating staff.

## Our mission

Give organizations that run guest houses a simple, reliable system to manage their properties, rooms and people, so that staff spend less time on administration and more time serving guests.

## Who Hospitia is for

| Audience | What they do in Hospitia |
|---|---|
| **Platform administrators** | Run the Hospitia installation: manage organization types, organizations, owners, currencies and default room amenities. |
| **Owners** | Represent an organization that owns one or more guest houses. Create their organization, appoint managers, and set up room types and rooms. |
| **Managers** | Run the day-to-day work of an organization's guest house: rooms, room types, amenities and customers. |
| **Customers** | Guests who sign up to use guest house services. |

The roles map directly to `UserType` in the backend (`ADMIN`, `OWNER`, `MANAGER`, `CUSTOMER`). See [Roles and permissions](../reference/roles-and-permissions.md).

## Principles

- **Built for organizations, not single hotels.** Every owner and manager works inside an [active organization](../architecture/active-organization.md), and one person can belong to several organizations.
- **Accessible by default.** The interface targets WCAG AA and must pass AXE checks, in light and dark themes. See [Accessibility](../standards/accessibility.md).
- **Small, independent services.** Each business area has its own service and database, connected by events. See [Architecture](../architecture/index.md).
- **Self-hostable.** The whole stack runs on one Linux server with Docker. See [Server setup and deployment](../operations/deployment.md).

!!! note "TODO"
    Owner to review this page and replace it with the official mission statement and tagline once they are agreed.
