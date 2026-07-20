# tsukuyomi
Tsukuyomi is a CLI tool that converts luau doc comments into mkdocs/zensical markdown files.
The goal of this tool is to improve usability for luau developers when creating documentation using zensical.

This is a pre v1.0 tool so expect more features to be added.

## installation:
Its reccomended to instal tsukuyomi using [rokit](https://github.com/rojo-rbx/rokit).

To install run this command:
```pwsh
rokit add chocolate-bar2410/tsukuyomi
```

## Commands:
- build (TARGET_DIRECTORY) (OUTPUT_DIRECTORY)
    - converts luau files from inside TARGET_DIRECTORY into markdown and inserts them into OUTPUT_DIRECTORY

- license
    - displays the license info this CLI tool.

## supported tags
- @class
- @within
- @method
- @param
- @return
- @prop

see [moonwave](https://eryn.io/moonwave/docs/TagList) for more info.

note: this is not moonwave, this is intended to be used along side zensical/material for mkdocs as a utility for generating docs.