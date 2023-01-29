# 3. Data and Types

Date: 2022-12-11

## Status

Accepted

## Context

We have a choice for class or value types in the data that we transmit back to client applications.

## Decision

We will use value types for all data transmitted back to the client. 

## Consequences

* Data transmitted back is considered to be a one way flow of data with the server (and thus TootClient and SDK) as the source of truth to the app.
* Values transmitted back are not observable themselves (they won't conform to ObservableObject for changes).
* Values will be provided by copy and not by reference, where possible