// External scanner for tree-sitter-xo: the newline terminator (core 1.3) and raw strings (core 1.6).

#include "tree_sitter/parser.h"

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

enum TokenType {
  TERMINATOR,
  STMT_TERMINATOR,
  RAW_STRING,
};

void *tree_sitter_xo_external_scanner_create(void) { return NULL; }
void tree_sitter_xo_external_scanner_destroy(void *payload) { (void)payload; }
unsigned tree_sitter_xo_external_scanner_serialize(void *payload, char *buffer) {
  (void)payload;
  (void)buffer;
  return 0;
}
void tree_sitter_xo_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  (void)payload;
  (void)buffer;
  (void)length;
}

static void advance(TSLexer *lexer) { lexer->advance(lexer, false); }
static void skip(TSLexer *lexer) { lexer->advance(lexer, true); }

static bool is_ident_char(int32_t c) {
  return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_';
}

// A line starting with one of these words continues the declaration above it (core 1.3).
static bool continues_with_word(TSLexer *lexer) {
  static const char *words[] = {"uses", "requires", "ensures", "invariant", "derive", "else", NULL};
  char buf[16];
  int n = 0;
  while (is_ident_char(lexer->lookahead) && n < 15) {
    buf[n++] = (char)lexer->lookahead;
    advance(lexer);
  }
  if (is_ident_char(lexer->lookahead)) {
    return false;
  }
  buf[n] = 0;
  for (int i = 0; words[i] != NULL; i++) {
    if (strcmp(buf, words[i]) == 0) {
      return true;
    }
  }
  return false;
}

static bool scan_terminator(TSLexer *lexer, bool in_block) {
  bool saw_newline = false;
  for (;;) {
    int32_t c = lexer->lookahead;
    if (c == ' ' || c == '\t' || c == '\r' || c == '\f') {
      skip(lexer);
    } else if (c == '\n') {
      saw_newline = true;
      skip(lexer);
      break;
    } else if (c == 0) {
      lexer->result_symbol = in_block ? STMT_TERMINATOR : TERMINATOR;
      return true;
    } else if (c == '/') {
      // a comment ends the line: look at what follows it
      lexer->mark_end(lexer);
      advance(lexer);
      if (lexer->lookahead != '/') {
        return false;
      }
      while (lexer->lookahead != '\n' && lexer->lookahead != 0) {
        advance(lexer);
      }
      if (lexer->lookahead == 0) {
        lexer->result_symbol = in_block ? STMT_TERMINATOR : TERMINATOR;
        return true;
      }
      saw_newline = true;
      advance(lexer);
      lexer->mark_end(lexer);
      goto lookahead;
    } else {
      return false;
    }
  }
  if (!saw_newline) {
    return false;
  }
  lexer->mark_end(lexer);

lookahead:
  // skip blank lines and comment lines, then decide whether the next line continues this one
  for (;;) {
    int32_t c = lexer->lookahead;
    if (c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\n') {
      advance(lexer);
    } else if (c == '/') {
      advance(lexer);
      if (lexer->lookahead != '/') {
        break;
      }
      while (lexer->lookahead != '\n' && lexer->lookahead != 0) {
        advance(lexer);
      }
    } else {
      break;
    }
  }
  int32_t c = lexer->lookahead;
  lexer->result_symbol = in_block ? STMT_TERMINATOR : TERMINATOR;
  if (c == 0) {
    return true;
  }
  if (c == '.') {
    advance(lexer);
    // `.` continues the line, `..` and `..=` start a new expression
    return lexer->lookahead == '.';
  }
  if (c == '{') {
    // a line starting with `{` opens the function body above it, except inside a block, where it is a block statement
    return in_block;
  }
  if (c == '-') {
    advance(lexer);
    return lexer->lookahead != '>';
  }
  if (is_ident_char(c)) {
    return !continues_with_word(lexer);
  }
  return true;
}

static bool scan_raw_string(TSLexer *lexer) {
  if (lexer->lookahead != 'r') {
    return false;
  }
  advance(lexer);
  int hashes = 0;
  while (lexer->lookahead == '#') {
    hashes++;
    advance(lexer);
  }
  if (lexer->lookahead != '"') {
    return false;
  }
  advance(lexer);
  int quotes = 1;
  if (lexer->lookahead == '"') {
    advance(lexer);
    if (lexer->lookahead == '"') {
      advance(lexer);
      quotes = 3;
    } else {
      // `r""` : an empty raw string (hashes must be 0 here for it to close)
      if (hashes == 0) {
        lexer->result_symbol = RAW_STRING;
        lexer->mark_end(lexer);
        return true;
      }
      quotes = 2;
    }
  }
  // scan to `quotes` quotes followed by `hashes` hashes
  for (;;) {
    if (lexer->lookahead == 0) {
      return false;
    }
    if (lexer->lookahead == '"') {
      int q = 0;
      while (lexer->lookahead == '"' && q < quotes) {
        q++;
        advance(lexer);
      }
      if (q == quotes) {
        int h = 0;
        while (lexer->lookahead == '#' && h < hashes) {
          h++;
          advance(lexer);
        }
        if (h == hashes) {
          lexer->result_symbol = RAW_STRING;
          lexer->mark_end(lexer);
          return true;
        }
      }
    } else {
      advance(lexer);
    }
  }
}

bool tree_sitter_xo_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
  (void)payload;
  bool term = valid_symbols[TERMINATOR] || valid_symbols[STMT_TERMINATOR];
  bool in_block = valid_symbols[STMT_TERMINATOR];
  while (lexer->lookahead == ' ' || lexer->lookahead == '\t' || lexer->lookahead == '\r' || lexer->lookahead == '\f') {
    skip(lexer);
  }
  int32_t c = lexer->lookahead;
  if (term && (c == '\n' || c == 0 || c == '/')) {
    return scan_terminator(lexer, in_block);
  }
  if (valid_symbols[RAW_STRING]) {
    while (c == '\n' || c == ' ' || c == '\t' || c == '\r') {
      skip(lexer);
      c = lexer->lookahead;
    }
    if (c == 'r') {
      return scan_raw_string(lexer);
    }
  }
  return false;
}
