# tsukuyomi
Tsukuyomi is a CLI tool that converts luau doc comments into mkdocs/zensical markdown files.

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

note: this is not moonwave, this is intended to be used along side zensical/mkdocs as a utility for generating docs.