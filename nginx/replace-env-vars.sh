#!/bin/sh

# Replaces environment variables in the bundle's index.html file with their respective values.
# This script is automatically picked up by the nginx entrypoint on startup.

set -e

INDEX_BUNDLE_PATH="/app/dashboard/index.html"

# Function to replace environment variables
replace_env_var() {
  var_name=$1
  # Get the variable value directly using parameter expansion
  eval "var_value=\"\$$var_name\""
  
  if [ -n "$var_value" ] && [ "$var_value" != "" ]; then
    echo "Setting $var_name to: $var_value"
    # Use # as delimiter in sed to avoid issues with URLs containing /
    # Escape special regex characters in the value
    escaped_value=$(printf '%s\n' "$var_value" | sed 's/[[\.*^$()+?{|]/\\&/g')
    sed -i "s#${var_name}: \"[^\"]*\"#${var_name}: \"${escaped_value}\"#g" "$INDEX_BUNDLE_PATH" 2>/dev/null || {
      # Fallback: try with different pattern matching
      sed -i "s#${var_name}: \".*\"#${var_name}: \"${escaped_value}\"#g" "$INDEX_BUNDLE_PATH"
    }
  else
    echo "No $var_name provided, using defaults."
  fi
}

# Replace each environment variable
replace_env_var "API_URL"
replace_env_var "APP_MOUNT_URI"
replace_env_var "APPS_MARKETPLACE_API_URL"
replace_env_var "EXTENSIONS_API_URL"
replace_env_var "APPS_TUNNEL_URL_KEYWORDS"
replace_env_var "IS_CLOUD_INSTANCE"
replace_env_var "LOCALE_CODE"

echo "Environment variable replacement complete."
