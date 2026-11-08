package tree_sitter_xo_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_xo "github.com/xo-lang/tree-sitter-xo/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_xo.Language())
	if language == nil {
		t.Errorf("Error loading Xo grammar")
	}
}
