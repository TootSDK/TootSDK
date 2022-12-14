# 4. Codable and Data

Date: 2022-12-11

## Status

Accepted

## Context

When data is transmitted back from TootClient, we need to ensure it's truly usable by the client in a variety of different ways. Clients may want to serialise or otherwise store the data provided back.

## Decision

To help facilitate this, we will ensure all public data types that are provided by the SDK conform to Codable. 

## Consequences

All data types in use publicly will need to conform to Codable, and this may have a knock on effect of requiring extra boiler plate code to facilitate this. This is acceptable where and when it shows up.
