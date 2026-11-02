# Exceptions and error codes

Backend errors are raised as custom exceptions and turned into a consistent JSON response by registered handlers. This guide adds a new one, using a "room not found" error in booking as the example.

## 1. Add the error code

Add a member to `ErrorCodes` in `<service>/types/error_codes.py`, using the next free number in the service's range:

| Range | Service |
|---|---|
| 1001–1999 | auth (also copied into the other services for shared errors) |
| 2001–2999 | booking |
| 3001–3999 | payment |
| 4001–4999 | dashboard |

```python
ROOM_NOT_FOUND = 2025
```

Never reuse or renumber an existing code: the frontend and API clients depend on them. Add the same code to the frontend's `ErrorCodes` enum (`src/app/types/enums/`) when the frontend needs to react to it.

## 2. Define the exception

In `exceptions/definitions/<category>_exceptions.py` (`not_found`, `validation`, `security`, `messaging_queue`, …), extend the service's `BaseException`:

```python
class RoomNotFoundException(BaseException):
    """
    Raised when a requested room does not exist, was deleted, or belongs to another organization.
    """

    def __init__(
        self,
        message: str = "The requested room was not found."
    ) -> None:
        super().__init__(ErrorCodes.ROOM_NOT_FOUND, message)
```

## 3. Handle it

In the matching `exceptions/handlers/` module, return a `JSONResponse` with the HTTP status and an `ApiErrorResponse` body, following the neighbouring handlers:

```python
def room_not_found_exception_handler(
    _request: Request,
    exc: RoomNotFoundException,
) -> JSONResponse:
    """Handle room not found exceptions (numpy-style docstring as in the neighbouring handlers)."""
    response = ApiErrorResponse(
        metadata=None,
        errorCode=exc.errorCode,
        message=exc.message,
    )
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content=response.model_dump(),
    )
```

## 4. Register it

Add the pair to `get_exception_handlers()` in `exceptions/registry.py`. Unregistered exceptions become 500 errors.

## 5. Document it on the route

Add an example in `doc/<category>_exception(s)_doc.py` and reference it in the route decorator, so Swagger UI and the [API reference](../reference/api/index.md) show the response:

```python
@router.get("/detail", responses={**NOT_FOUND_EXCEPTIONS_DOC["RoomNotFoundException"]})
```

## 6. Raise it

Raise the exception from the **service** (or repository) layer, not from the route.

## 7. Update the docs

Add the code to [Error codes](../reference/error-codes.md) and re-export the API reference with `bash scripts/export_openapi.sh`.

## Status codes in use

| Status | Used for |
|---|---|
| 400 | Invalid input and business rules (weak password, invalid username, missing active-organization header, amenity not available) |
| 401 | Missing, invalid or expired token; wrong role (`UNAUTHORIZED`) |
| 403 | Access forbidden to an existing resource (organization access, active organization invalid, default amenity) |
| 404 | Not found (including an unknown message queue, `MQ_NOT_FOUND`) |
| 409 | Conflicts: already exists, in use, has active dependencies |
| 500 | Message publishing failures and unhandled errors |

Check the neighbouring handlers for the exact status of each category before adding a new one.
