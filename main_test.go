package main

import "testing"

func TestFormatPermissions(t *testing.T) {
	perms := formatPermissions(0755)
	if perms != "-rwxr-xr-x" {
		t.Errorf("Expected rwxr-xr-x, got %s", perms)
	}
}
