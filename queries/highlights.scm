; Highlights for Xo (spec/core.md). Capture names follow nvim-treesitter, Helix and Zed.

; ---- comments ----
(comment) @comment
(doc_comment) @comment.documentation

; ---- identifiers, broadest first (later patterns win) ----
(identifier) @variable

((identifier) @constant
  (#match? @constant "^[A-Z][A-Z0-9_]*$"))

((identifier) @type
  (#match? @type "^[A-Z][A-Za-z0-9]*[a-z][A-Za-z0-9]*$"))

((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))

((identifier) @constant.builtin
  (#any-of? @constant.builtin "Ok" "Err" "Some" "None" "true" "false"))

((identifier) @function.builtin
  (#any-of? @function.builtin "dbg" "fault" "expect" "embed"))

; ---- declarations ----
(function_declaration name: (identifier) @function)
(function_signature name: (identifier) @function)
(receiver name: (identifier) @variable.parameter)
(receiver type: (_) @type)
(struct_declaration name: (identifier) @type)
(enum_declaration name: (identifier) @type)
(interface_declaration name: (identifier) @type)
(type_declaration name: (identifier) @type)
(const_declaration name: (identifier) @constant)
(type_parameter name: (identifier) @type)
(variant name: (identifier) @constructor)
(field_declaration name: (identifier) @property)
(derive_item (identifier) @type)
(derive_arg (identifier) @property)
(test_declaration name: (_) @string.special)

; ---- parameters ----
(parameter name: (identifier) @variable.parameter)
(closure_parameter name: (identifier) @variable.parameter)
(argument name: (identifier) @variable.parameter)

; ---- types ----
(qualified_type (identifier) @type)
(optional_type "?" @type)
(error_spec "!" @operator)

; ---- effects ----
(effect (identifier) @attribute)
(uses_clause "uses" @keyword)

; ---- expressions ----
(call_expression function: (identifier) @function.call)
(call_expression function: (field_expression field: (identifier) @function.method.call))
((call_expression function: (identifier) @constructor)
  (#match? @constructor "^[A-Z]"))
(field_expression field: (identifier) @property)
(field_expression field: (tuple_index) @number)
(field_initializer name: (identifier) @property)
(struct_literal type: (identifier) @type)
(struct_literal type: (identifier) @type)
(variant_pattern name: (identifier) @constructor)
(qualified_pattern name: (identifier) @constructor)
(pattern_field name: (identifier) @property)
(wildcard_pattern) @variable.builtin
(labeled_statement label: (identifier) @label)
(break_statement (identifier) @label)
(continue_statement (identifier) @label)
(scope_expression keyword: (identifier) @keyword (#eq? @keyword "scope"))
(scope_expression name: (identifier) @label)
(hole) @keyword.exception

; ---- use ----
(use_declaration path: (import_path) @module)
(use_declaration alias: (identifier) @module)

; ---- literals ----
(string) @string
(multiline_string) @string
(raw_string) @string
(bytes_literal) @string
(string_content) @string
(bytes_content) @string
(escape_sequence) @string.escape
(interpolation "${" @punctuation.special "}" @punctuation.special)
(interpolation ":?" @punctuation.special)
(rune_literal) @character
(int_literal) @number
(float_literal) @number.float
(duration_literal) @number
(boolean_literal) @boolean

; ---- operators and punctuation ----
[
  "+" "-" "*" "/" "%" "<<" ">>" "&" "|" "^" "~" "!"
  "==" "!=" "<" "<=" ">" ">=" "&&" "||" "??" "?"
  ".." "..=" "=" "+=" "-=" "*=" "/=" "%=" "=>" "->"
] @operator

["(" ")" "[" "]" "{" "}" "#{"] @punctuation.bracket
["," ":" "." ";"] @punctuation.delimiter

; ---- keywords ----
[
  "fn" "let" "var" "const" "struct" "enum" "interface" "type" "test" "use" "pub"
] @keyword

[
  "if" "else" "match" "for" "while" "in" "break" "continue" "return" "defer" "select" "after"
] @keyword.control

[
  "requires" "ensures" "invariant" "derive" "with" "is" "as" "bound" "seed" "link"
] @keyword
