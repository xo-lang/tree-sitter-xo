; Scopes, definitions and references for Xo.

[
  (source_file)
  (function_declaration)
  (function_literal)
  (block)
  (match_arm)
  (for_statement)
  (while_statement)
  (if_expression)
] @local.scope

(let_statement pattern: (identifier) @local.definition.var)
(var_statement pattern: (identifier) @local.definition.var)
(let_statement pattern: (tuple_pattern (identifier) @local.definition.var))
(var_statement pattern: (tuple_pattern (identifier) @local.definition.var))
(for_statement pattern: (identifier) @local.definition.var)
(for_statement pattern: (tuple_pattern (identifier) @local.definition.var))
(parameter name: (identifier) @local.definition.parameter)
(closure_parameter name: (identifier) @local.definition.parameter)
(const_declaration name: (identifier) @local.definition.constant)
(function_declaration name: (identifier) @local.definition.function)
(match_arm pattern: (identifier) @local.definition.var)
(variant_pattern (pattern_field (identifier) @local.definition.var))
(struct_declaration name: (identifier) @local.definition.type)
(enum_declaration name: (identifier) @local.definition.type)
(interface_declaration name: (identifier) @local.definition.type)
(type_declaration name: (identifier) @local.definition.type)

(identifier) @local.reference
