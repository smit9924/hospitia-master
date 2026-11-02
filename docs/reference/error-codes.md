# Error codes

Every error response has an `errorCode` (see [Requests and responses](../backend/index.md#requests-and-responses)). Codes are defined per service in `<service>/types/error_codes.py`. Never reuse or renumber a code. How to add one: [Exceptions and error codes](../guides/exceptions-and-error-codes.md).

## Shared codes (1xxx)

Defined in auth and copied into booking, dashboard and payment, so the same code means the same thing everywhere.

| Code | Name | Meaning |
|---|---|---|
| 1001 | `PUBLIC_EMAIL_NOW_ALLOWED` | Public email domains aren't allowed; a business address is required |
| 1002 | `USER_WITH_EMAIL_ALREADY_EXIST` | A user with this email already exists |
| 1003 | `USER_WITH_USENAME_ALREADY_EXIST` | A user with this username already exists |
| 1004 | `UNAUTHORIZED` | Not authenticated, or the role / email verification doesn't allow this |
| 1005 | `INVALIDTOKEN` | Token invalid, expired or of the wrong type |
| 1006 | `INVALID_CREDENTIALS` | Wrong username/email or password |
| 1007 | `USER_NOT_FOUND` | User not found |
| 1008 | `WEAK_PASSWORD` | Password doesn't meet the strength rules |
| 1009 | `INVALID_USERNAME` | Username format not allowed |
| 1010 | `MQ_NOT_FOUND` | Unknown message queue or destination |
| 1011 | `MQ_MESSAGE_PUBLISH_FAILED` | Publishing a message failed |
| 1012 | `EMAIL_ALREADY_VERIFIED` | Email is already verified |
| 1013 | `INVALID_OTP` | Verification code wrong or expired |

The names `PUBLIC_EMAIL_NOW_ALLOWED`, `USER_WITH_USENAME_ALREADY_EXIST` and `INVALIDTOKEN` contain historical typos; they're kept because clients depend on them.

## booking (2xxx)

| Code | Name | Meaning |
|---|---|---|
| 2001 | `HANDLER_NOT_FOUND` | No message handler for a queue |
| 2002 | `ORGANIZATION_TYPE_NOT_FOUND` | Organization type not found |
| 2003 | `ORGANIZATION_TYPE_ALREADY_EXISTS` | Organization type name taken |
| 2004 | `ORGANIZATION_TYPE_HAS_ACTIVE_ORGANIZATIONS` | Can't remove a type that active organizations use |
| 2005 | `ADDRESS_NOT_FOUND` | Address not found |
| 2006 | `ORGANIZATION_NOT_FOUND` | Organization not found |
| 2007 | `ORGANIZATION_HAS_ACTIVE_DEPENDENCIES` | Can't remove an organization with active dependencies |
| 2008 | `ORGANIZATION_MUST_HAVE_ACTIVE_OWNER` | An organization must keep an active owner |
| 2009 | `ORGANIZATION_USER_MAPPING_NOT_FOUND` | Membership not found |
| 2010 | `USER_ROLE_MISMATCH_FOR_ORGANIZATION` | User's role doesn't fit the requested membership |
| 2011 | `ORGANIZATION_ACCESS_FORBIDDEN` | Caller may not access this organization |
| 2012 | `ACTIVE_ORGANIZATION_REQUIRED` | `X-Active-Organization-Guid` missing or not a UUID |
| 2013 | `ACTIVE_ORGANIZATION_INVALID` | Active organization not found, inactive, or caller not a member |
| 2014 | `CURRENCY_UNIT_NOT_FOUND` | Currency unit not found |
| 2015 | `CURRENCY_UNIT_ALREADY_EXISTS` | Currency unit already exists |
| 2016 | `CURRENCY_UNIT_IN_USE` | Currency unit used by room types |
| 2017 | `ROOM_AMENITY_NOT_FOUND` | Room amenity not found |
| 2018 | `ROOM_AMENITY_ALREADY_EXISTS` | Room amenity name taken |
| 2019 | `ROOM_AMENITY_IN_USE` | Room amenity used by room types |
| 2020 | `ROOM_AMENITY_MODIFICATION_FORBIDDEN` | Only admins can manage default room amenities |
| 2021 | `ROOM_TYPE_NOT_FOUND` | Room type not found |
| 2022 | `ROOM_TYPE_ALREADY_EXISTS` | Room type name taken in the organization |
| 2023 | `ROOM_TYPE_AMENITY_NOT_AVAILABLE` | Amenity not available to the organization |
| 2024 | `ROOM_TYPE_ORGANIZATION_REQUIRED` | Admin must name the organization |
| 2025 | `ROOM_NOT_FOUND` | Room not found |
| 2026 | `ROOM_ALREADY_EXISTS` | Room number taken in the organization |
| 2027 | `ROOM_ORGANIZATION_REQUIRED` | Admin must name the organization |
| 2028 | `ROOM_TYPE_NOT_AVAILABLE_FOR_ROOM` | Selected room type isn't available for the room's organization |
| 2029 | `ROOM_TYPE_IN_USE` | Room type used by rooms |

## payment (3xxx)

| Code | Name | Meaning |
|---|---|---|
| 3001 | `HANDLER_NOT_FOUND` | No message handler for a queue |

## dashboard (4xxx)

| Code | Name | Meaning |
|---|---|---|
| 4001 | `HANDLER_NOT_FOUND` | No message handler for a queue |

notification has no `ErrorCodes` enum.
