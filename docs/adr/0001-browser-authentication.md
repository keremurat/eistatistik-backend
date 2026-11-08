# ADR 0001: Browser Authentication

- Status: Accepted
- Date: 2026-11-03

## Context

The new system separates the Next.js frontend from the Rails API. The original
Rails monolith uses Devise with server-rendered redirects and flash messages.
The new application needs JSON responses while retaining browser-friendly
session security.

## Decision

Use Devise with Rails' server-side session semantics and an encrypted,
`HttpOnly` session cookie.

- Devise owns identity authentication, password hashing, confirmation,
  password reset, session timeout, and account locking.
- API controllers return JSON; they do not redirect to HTML sign-in pages.
- The browser never stores a bearer token in `localStorage` or
  `sessionStorage`.
- State-changing browser requests require CSRF protection.
- Authentication and authorization remain separate: Devise answers "who is
  this?"; policies answer "may this user do this?".
- Browser traffic will reach Rails through a same-origin `/api` path in the
  deployed topology. This avoids making cross-origin cookies and permissive
  CORS part of the security design.

## Initial Devise Modules

- `database_authenticatable`
- `registerable`
- `recoverable`
- `rememberable`
- `validatable`
- `confirmable`
- `lockable`
- `timeoutable`
- `trackable`

## Security Defaults

- Password length: 12 to 128 characters.
- Email comparison is case-insensitive and surrounding whitespace is removed.
- Unconfirmed accounts cannot sign in.
- Email changes require reconfirmation.
- Password-reset links expire after two hours.
- Sessions time out after two hours of inactivity.
- Ten failed attempts lock an account for one hour.
- Authentication failures use generic responses to reduce account discovery.

These are application defaults, not permanent business rules. Changes require
tests and an update to this ADR.

## Consequences

- Rails API mode must explicitly restore cookie and session middleware.
- JSON Devise controllers and a CSRF bootstrap endpoint are required.
- Next.js server-side requests that act for a browser must deliberately forward
  that browser's cookie; service-to-service calls must not impersonate a user.
- Production requires HTTPS so the session cookie can be marked `Secure`.
- Confirmation, reset, and unlock mail delivery must be configured before the
  corresponding flows are considered production-ready.

## Rejected Alternatives

- JWT in browser storage: increases exposure to token theft through XSS and
  adds token rotation/revocation complexity that this first-party web app does
  not need.
- Copying the monolith controllers unchanged: they produce redirects and flash
  messages rather than a stable JSON contract.
