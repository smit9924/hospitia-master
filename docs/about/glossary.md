# Glossary

Domain and technical terms used in the code, the interface and these docs. Use these names consistently in code, UI text and documentation.

| Term | Meaning | In the code |
|---|---|---|
| **Active organization** | The organization an owner or manager is currently working in. The frontend sends it on every booking request; the backend validates it. | `X-Active-Organization-Guid` header, `ActiveOrganizationDep` (booking) |
| **Address** | The postal address of an organization (lines, landmark, city, state, country, postal code). | `addresses` table (booking) |
| **Admin** | Platform administrator with access to every organization. | `UserType.ADMIN` (1) |
| **Amenity** (room amenity) | A facility a room type offers, such as Wi-Fi. *Default* amenities (no organization) are managed by admins and shared; organization amenities belong to one organization. | `room_amenities` table (booking) |
| **Currency unit** | An ISO 4217 currency used for room prices. | `currency_units` table (booking) |
| **Customer** | A guest using guest house services. | `UserType.CUSTOMER` (4) |
| **Dead-letter queue** | A queue that receives a message after its processing failed the configured number of times. | `*_DEAD_LETTER_EMAIL_QUEUE` settings (notification) |
| **Error code** | A numeric code in every error response that identifies the error. | `ErrorCodes` in `<service>/types/error_codes.py` |
| **GUID** | The public identifier of a record. APIs expose GUIDs; numeric `id`s stay internal. | `guid` columns, `GUIDMixin` |
| **Internal API** | An endpoint callable only from the same machine (loopback address), without a JWT. | `InternalRequestDep` (auth) |
| **Internal user** | A service account reserved for internal use. Never a public role. | `UserType.INTERNALE` (5) |
| **Manager** | Runs an organization's guest house day to day. | `UserType.MANAGER` (3) |
| **Membership** (organization user mapping) | The link between a user and an organization; can be active or inactive. | `organization_user_mapping` table (booking) |
| **Organization** | An NGO or similar body that runs one or more guest houses. | `organizations` table (booking) |
| **Organization type** | A category of organization, such as trust or foundation. | `organization_types` table (booking) |
| **Outbox** | A table where auth stores events in the same transaction as the data change; a worker publishes them afterwards. | `users_outbox` table, `auth/outbox/` |
| **Owner** | Represents an organization that owns guest houses. | `UserType.OWNER` (2) |
| **Room** | A bookable room of an organization, with number, floor, type and status. | `rooms` table (booking) |
| **Room status** | `AVAILABLE`, `UNDER_MAINTENANCE` or `OUT_OF_SERVICE`. | `RoomStatus` (booking) |
| **Room type** | A kind of room in an organization: capacity, cost per night, currency and amenities. | `room_types` table (booking) |
| **User replica** | A copy of the user data a service needs, kept in sync from auth's user-created events. | `usersreplica` table (booking, dashboard, payment) |
| **User type / role** | The single role a user has. | `UserType` enum |
