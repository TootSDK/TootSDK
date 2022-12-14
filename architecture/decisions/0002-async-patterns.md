# 2. Async patterns

Date: 2022-12-11

## Status

Accepted

## Context

There are many choices for asynchronous code, and patterns for transmitting data asychronously back to the function that called for it (Delegation, callbacks, async/await, async sequences, etc)

## Decision

* In TootSDK we will favour async/await calls throughout where calls need to run asynchronously to deliver data.
* We will use Async Sequences to publish updates to values over time back to a client

## Consequences

This may be limiting for some clients, if they do not want to use Async/Await. In this case, TootSDK will not be for those clients.
