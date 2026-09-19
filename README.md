# qualified.vim

Treat a name such as `Foo::Bar` or `std::collections::HashMap` as one Vim
text object. Place the cursor anywhere in the name, including either colon,
and use `iq` with a standard operator.

## Requirements

- Vim 9.0 or later with `+vim9script` (Neovim is not supported).
- No external commands or dependencies.

## Installation

With Vim's built-in packages, clone into a `pack/*/start/` directory:

```sh
git clone https://github.com/eeekcct/qualified.vim.git ~/.vim/pack/plugins/start/qualified.vim
```

On Windows, use `~/vimfiles/pack/plugins/start/qualified.vim` instead.
Restart Vim, then run `:helptags ALL` to make `:help qualified` available.

Or add `eeekcct/qualified.vim` using your preferred plugin manager.

## Usage

| Keys | Action |
| --- | --- |
| `viq` | Select the qualified name |
| `ciq` | Change the qualified name |
| `diq` | Delete the qualified name |
| `yiq` | Yank the qualified name |

These use Vim's standard operators, including named registers and `.` repeat
for changes. Only `iq` is mapped, in Visual and Operator-pending modes.
There is no `aq` text object or separate change/delete/yank command.

## Recognized names

Names must contain at least one `::`, with no spaces or line breaks:

```text
Foo::Bar
Foo::Bar::Baz
::Foo
::Foo::Bar
ActiveRecord::Base
std::collections::HashMap
crate::parser::Token
self::foo::Bar
super::parser::Token
Self::Error
```

The same syntax works in Ruby, Rust, C++, and other file types. Each identifier
starts with an ASCII letter or underscore, followed by ASCII letters, digits,
or underscores. Unicode identifiers and Rust raw identifiers (`r#name`) are
outside the v1 grammar; this is a text object, not a language parser.

Single identifiers (`Foo`, `HashMap`, `foo`), single-colon expressions
(`path: &Path`, `foo:bar`, `key:value`), and spaced names (`Foo :: Bar`)
are not selected. Malformed candidates such as `Foo::`, `::`, `Foo::::Bar`,
`::Foo::`, and `Foo::Bar::` are rejected in full.

Only the current line is examined. A name split across lines is not joined.
With the cursor outside a recognized name, an operator is cancelled without
changing text or registers; in Visual mode, the existing selection is kept.
Counts do not extend the object to other names.

The plugin does not change `'iskeyword'`, so `w`, `b`, `iw`, `*`, and `#`
keep their normal behavior. See `:help qualified` for details.

## Development

Run the regression tests from the repository root:

```sh
vim -Nu NONE -i NONE -n -es -S test/run.vim
```

Tests exercise the mappings with actual key input, including valid and invalid
names, every cursor position, selection settings, register preservation,
Visual mode, repeated edits, and plugin reloads. Failures are written to
`test-errors.log`.

## License

[MIT](LICENSE)
