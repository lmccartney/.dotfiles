; extends

; ===================================================================
; SQL injection into Python strings
; ===================================================================

; -------------------------------------------------------------------
; Variable name heuristic
; Works for regular strings, triple-quoted strings, and f-strings.
; injection.combined merges f-string fragments for proper parsing.
; -------------------------------------------------------------------

; Matches any variable containing "sql" (case-insensitive)
(assignment
  left: (identifier) @_varname
  right: (string
    (string_content) @injection.content)
  (#lua-match? @_varname "^[%w_]*[Ss][Qq][Ll][%w_]*$")
  (#set! injection.language "sql")
  (#set! injection.combined))

; Matches exact names: query, statement
(assignment
  left: (identifier) @_varname
  right: (string
    (string_content) @injection.content)
  (#any-of? @_varname "query" "statement")
  (#set! injection.language "sql")
  (#set! injection.combined))

; Matches *query, *Query suffix pattern
(assignment
  left: (identifier) @_varname
  right: (string
    (string_content) @injection.content)
  (#lua-match? @_varname "^[%w_]*[Qq]uery$")
  (#set! injection.language "sql")
  (#set! injection.combined))

; Matches *statement, *Statement suffix pattern
(assignment
  left: (identifier) @_varname
  right: (string
    (string_content) @injection.content)
  (#lua-match? @_varname "^[%w_]*[Ss]tatement$")
  (#set! injection.language "sql")
  (#set! injection.combined))

; -------------------------------------------------------------------
; Comment annotation: # language=sql
; Place directly above a string assignment to force SQL injection.
; -------------------------------------------------------------------
((comment) @_lang_comment
  .
  (expression_statement
    (assignment
      right: (string
        (string_content) @injection.content)))
  (#lua-match? @_lang_comment "^#%s*language%s*=%s*sql%s*$")
  (#set! injection.language "sql")
  (#set! injection.combined))
