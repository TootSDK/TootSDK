# TootSDK Release 🎺

This is a utility for TootSDK, that posts to Mastodon, based on GitHub releases.
This is designed primarily for TootSDK's release, but may show a view of how to automate this sort of thing for another project.

## Available commands

To view the current list of commands, build the project and run the program using the `-h` option:

```
swift build && ./.build/debug/tootsdk-release -h
```

### Generate post

`make-post`

```
USAGE: toot-sdk-release make-post -u <u> -t <t>

OPTIONS:
  -u <u>                  URL to the instance to connect to
  -t <t>                  Access token for an account with sufficient permissions.
  
```

## Local development

To test it out, you could run:

```shell
swift build && ./.build/debug/tootsdk-release make-post -u "..." -t "..."
```
