# Routes and guards

This guide adds a page to the main Angular app and controls who can open it.

## 1. Add the path constant

Add the full path to `appRoutes` in `src/app/data/app-routes.ts`, grouped with related routes:

```typescript
roomListing: '/organization/room/listing',
```

Navigate with `appRoutes.*` everywhere; don't repeat path strings.

## 2. Register the route

Add the route in `src/app/app.routes.ts`, inside the matching parent, with its guards and allowed roles:

```typescript
{
  path: 'listing',
  component: RoomListing,
  canActivate: [permissionGuard],
  data: {
    requiredPermission: [UserType.ADMIN, UserType.OWNER, UserType.MANAGER],
  },
},
```

Existing routes register components directly; follow that pattern within existing feature areas. See [Angular standards](../standards/frontend-angular.md#routing) for when to lazy-load.

## 3. Pick the guard

| Guard | Use for | Route data |
|---|---|---|
| `permissionGuard` | Any page for signed-in users | `requiredPermission: UserType[]`: roles allowed; others go to `/error/403`. Optional `requireEmailVerified` (default `true`; unverified users go to `/auth/verify-email`) and `requireActiveOrganization` (default `true`; owners and managers without an active organization are sent to onboarding or selection). Set them to `false` only for pages that must work before verification or onboarding. |
| `authRedirectionGuard` | Sign-in, sign-up, password pages | none; signed-in users are sent to their home route |
| `organizationOnboardingGuard` | Onboarding pages (with `permissionGuard`) | `onboardingFor: UserType`: only that role, without an active organization, may open the page |

Never check roles inside a component to hide a whole page; use the guard. Hiding individual controls by role in a template is fine.

## 4. Add it to the sidebar (if it's a menu destination)

Add an item to `src/app/data/sidebar-navigation.ts` with its icon and allowed roles. The sidebar only shows items the user's role may open.

## 5. Make sure the backend agrees

Frontend guards are for user experience; the backend enforces access. The `requiredPermission` roles must match the `RoleValidationDep` roles of the endpoints the page calls. See [Roles and permissions](../reference/roles-and-permissions.md).

## 6. Check it

Sign in as each role and open the URL directly: allowed roles see the page, others land on `/error/403`, signed-out users are sent to `/auth/login`.
