# Your first frontend page

In this tutorial you'll add a **Room status** page to the main app that shows how many rooms are available, under maintenance or out of service. It uses the endpoint from [Your first backend endpoint](first-backend-endpoint.md). You'll add an API route, a service method, a standalone component with signals, a guarded route and a sidebar link, and check accessibility in both themes. It takes about 40 minutes.

!!! info "Exercise"
    Work on a throwaway branch in `hospitia-frontend` (and keep the backend tutorial's branch running in booking). Delete both when you're done.

All paths below are under `frontend/clients/main/src/app/`.

## 1. Add the endpoint URL

Every API URL lives in `data/api-routes.ts`, built from the environment's base URL. Add to the `room` group:

```typescript
room: {
  // …existing entries
  statusSummary: `${apiBaseUrls.booking}/room/status-summary`,
},
```

## 2. Add the type and service method

Add the response shape to `types/interfaces/room.ts`:

```typescript
export interface RoomStatusSummary {
  available: number;
  underMaintenance: number;
  outOfService: number;
}
```

Add a method to the existing `Room` service in `services/room/room.ts`:

```typescript
getStatusSummary(): Observable<RoomStatusSummary> {
  return this.http.get<RoomStatusSummary>(apiRoutes.room.statusSummary);
}
```

You don't add headers: `authInterceptor` adds the bearer token and `activeOrganizationInterceptor` adds `X-Active-Organization-Guid` to every booking request.

## 3. Create the component

Create `components/room/room-status-overview/room-status-overview.ts`. It's a standalone component (no `standalone: true`, it's the default), uses `inject()`, keeps state in signals and derives values with `computed()`:

```typescript
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { PageHeader } from '../../common/page-header/page-header';
import { Room } from '../../../services/room/room';
import { RoomStatusSummary } from '../../../types/interfaces/room';

/** Number of active rooms per status in the active organization. */
@Component({
  selector: 'app-room-status-overview',
  imports: [PageHeader],
  templateUrl: './room-status-overview.html',
  styleUrl: './room-status-overview.scss',
})
export class RoomStatusOverview implements OnInit {
  private readonly roomService = inject(Room);

  protected readonly titleText = $localize`Room status`;
  protected readonly summary = signal<RoomStatusSummary | null>(null);
  protected readonly total = computed(() => {
    const summary = this.summary();
    return summary ? summary.available + summary.underMaintenance + summary.outOfService : 0;
  });

  ngOnInit(): void {
    this.roomService.getStatusSummary().subscribe((summary) => this.summary.set(summary));
  }
}
```

Create `room-status-overview.html`. Use native control flow, the shared page classes from `_page-patterns.scss` and `_utils.scss`, `i18n` for every user-facing string, and the review comments:

```html
<div class="w-100">
  <app-page-header [titleText]="titleText" />

  <div class="page-container">
    <!-- Section: Room status summary -->
    @if (summary(); as summary) {
      <section class="listing-card rounded-12 pr-16 pl-16 pt-16 pb-16 w-100" aria-labelledby="room-status-total">
        <!-- TEXT: Total rooms -->
        <p id="room-status-total" i18n>{{ total() }} active rooms</p>

        <ul>
          <!-- TEXT: Available -->
          <li i18n>Available: {{ summary.available }}</li>
          <!-- TEXT: Under maintenance -->
          <li i18n>Under maintenance: {{ summary.underMaintenance }}</li>
          <!-- TEXT: Out of service -->
          <li i18n>Out of service: {{ summary.outOfService }}</li>
        </ul>
      </section>
    }
  </div>
</div>
```

Create an empty `room-status-overview.scss`. Only add component styles that are truly specific to this page, using theme tokens (`var(--mat-sys-*)`), never hex colors. See [HTML and SCSS standards](../standards/html-and-scss.md).

## 4. Register the route

Add the path to `data/app-routes.ts`:

```typescript
roomStatus: '/organization/room/status',
```

Then, in `app.routes.ts`, add a child to the existing `room` route next to `listing` and `create`, with the same guard and roles as the endpoint allows:

```typescript
{
  path: 'status',
  component: RoomStatusOverview,
  canActivate: [permissionGuard],
  data: {
    requiredPermission: [UserType.ADMIN, UserType.OWNER, UserType.MANAGER],
  },
},
```

`permissionGuard` sends other roles to `/error/403`, unverified users to email verification, and owners and managers without an active organization to onboarding. See [Routes and guards](../guides/routes-and-guards.md).

## 5. Add a sidebar link

In `data/sidebar-navigation.ts`, add an entry to the **Property** group after **Rooms**, following the neighbouring entries (`label`, `description`, `icon`, `route: appRoutes.roomStatus`, `allowedRoles: organizationMemberRoles`).

## 6. Check it

1. `npm start`, sign in as the owner from the [Product tour](product-tour.md), and open **Room status** from the sidebar.
2. Switch between light and dark theme: everything stays readable.
3. Keyboard only: <kbd>Tab</kbd> reaches the sidebar link and the page; focus is visible.
4. Run the axe DevTools extension on the page in both themes and fix any violation.
5. Sign in as a customer and open `/organization/room/status` directly: you land on the 403 page.
6. Add `room-status-overview.spec.ts` (copy the shape of `room-listing.spec.ts`), then run `npm run lint` and `npm test`.
7. Extract the new strings: run the **i18n : main-client (ng extract-i18n)** VS Code task.

## What you learned

- Where frontend code goes: `data/` for constants, `services/` for API calls, `components/<feature>/` for UI, `types/` for shapes.
- How interceptors add authentication and the active organization for you.
- How routes are protected and how pages stay accessible and themeable.

Next: [Your first message flow](first-message-flow.md).
