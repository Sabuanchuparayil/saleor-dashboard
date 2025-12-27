#!/bin/sh

# Replaces environment variables in the bundle's index.html file with their respective values.
# This script is automatically picked up by the nginx entrypoint on startup.

set -e

INDEX_BUNDLE_PATH="/app/dashboard/index.html"

# Debug: List available environment variables (excluding sensitive ones)
echo "Available environment variables:"
env | grep -E "^API_URL=|^APP_MOUNT_URI=|^APPS_" | head -10 || echo "No matching env vars found"

# Function to replace environment variables
replace_env_var() {
  var_name=$1
  # Try multiple methods to get the variable value
  # Method 1: Direct parameter expansion
  eval "var_value=\"\$$var_name\""
  
  # Method 2: If empty, try reading from env
  if [ -z "$var_value" ] || [ "$var_value" = "" ]; then
    var_value=$(env | grep "^${var_name}=" | cut -d'=' -f2- || echo "")
  fi
  
  # Remove any quotes that might have been included
  var_value=$(echo "$var_value" | sed "s/^['\"]//; s/['\"]$//")
  
  if [ -n "$var_value" ] && [ "$var_value" != "" ]; then
    echo "Setting $var_name to: $var_value"
    # Escape special regex characters in the value (especially / for URLs)
    escaped_value=$(printf '%s\n' "$var_value" | sed 's/[[\.*^$()+?{|]/\\&/g' | sed 's|/|\\/|g')
    # The built index.html has format: API_URL: "value"
    # Try multiple sed patterns to ensure replacement works
    # Pattern 1: API_URL: "anything"
    sed -i "s/${var_name}: \"[^\"]*\"/${var_name}: \"${escaped_value}\"/g" "$INDEX_BUNDLE_PATH" 2>/dev/null || \
    # Pattern 2: "API_URL": "anything" (JSON format)
    sed -i "s/\"${var_name}\": \"[^\"]*\"/\"${var_name}\": \"${escaped_value}\"/g" "$INDEX_BUNDLE_PATH" 2>/dev/null || \
    # Pattern 3: Fallback with .* (less safe but might work)
    sed -i "s/${var_name}: \".*\"/${var_name}: \"${escaped_value}\"/g" "$INDEX_BUNDLE_PATH" 2>/dev/null || {
      echo "Warning: Failed to replace $var_name in $INDEX_BUNDLE_PATH"
      # Debug: Show what's in the file
      grep -A 2 -B 2 "$var_name" "$INDEX_BUNDLE_PATH" | head -5 || true
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
