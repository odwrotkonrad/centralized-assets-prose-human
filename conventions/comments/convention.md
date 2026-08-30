# Commenting Convention

Every comment carries a label prefix: the reader decides upfront whether to read on, tooling greps by kind. An unprefixed comment has no defined purpose.

## Syntax

| Token | Meaning |
| ----- | ------- |
| `[where]` | related reads, sources, references |
| `[why]` | why it exists, purpose, why chosen over else |
| `[what]` | what it is |
| `[>]` `[<]` | section start, end (leader + N extra leaders, N = depth from top) |
| 🤖 🤖🤖 🤖🤖🤖 | AI-generated section |

## AI-Generated Content

AI-generated content sits in a section named with one or more 🤖. The count says how much **more** human attention is wanted: 🤖🤖🤖 a lot, 🤖🤖 some, 🤖 a little.

## Sectioning

A section opens with `[>]` and closes with `[<]`, both carrying the section name. Nesting repeats the file's comment leader (its first character) once per level of depth. Leader `#`: top `##[>] x`, nested `###[>] x`. Leader `//`: `///[>] x`, `////[>] x`.

## Example

Commented files in `example/`: `example.go` (leader `//`), `example.zsh` (leader `#`). Inline, block and section forms, 🤖 marks.
