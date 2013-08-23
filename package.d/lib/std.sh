#!/bin/echo You shall not invoke!

#
# Echo to stderr
debg() {
  echo "[DEBUG] $@" >&2
}

#
# Set by reference
# Invoke Rset [varname] [value]
Rset() {
  debg "rset ($0 | $1, $2, $3)"
  eval "$1='$2'"
}

#
# Extend the given path and export it
# while implementing linewise-tokens
# Stripping can  be suppressed with colons
exx() {
  debg "rxx ($0 | $1, $2, $3)"
  local ref OL NU filter
 
  filter='
   # ADDR      # COMMAND    # COMMENT
   ###################################################
                            #
                s/^\s*//    # STRIP start of line
                s/\s*$//    # STRIP end of line
                            #
                s/:/\n/     # colon to newline
                            #
    2,$         s/^/:/      # Prepend colon to all lines but first and last
                            # 
    /[^:\s*]/   p           # Filter empty lines
  '

  ref="$1"
  OL="${!ref}"

  # Apply transformations to STDIN
  NU="$(sed -n "$filter" | tr -d '\n')"

  # Write to var
  Rset "$ref" "${NU}${OL}"
  export "$ref"
  
  # DEBUG
  debg "Extend env: ${ref}=${!ref}"
}

mkcd() {
  mkdir -p "$1"
    cd "$1"
}

