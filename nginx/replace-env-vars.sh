#!/bin/sh

# Replaces environment variables in the bundle's index.html file with their respective values.
# This script is automatically picked up by the nginx entrypoint on startup.

set -e

INDEX_BUNDLE_PATH="/app/dashboard/index.html"

# Debug: List all environment variables (for troubleshooting)
# Uncomment the next line if you need to debug
# env | grep -E "API_URL|APP_MOUNT" || true

# Function to replace environment variables using direct parameter expansion
replace_env_var() {
  var_name=$1
  # Direct parameter expansion - more reliable than eval
  case "$var_name" in
    API_URL) var_value="$API_URL" ;;
    APP_MOUNT_URI) var_value="$APP_MOUNT_URI" ;;
    APPS_MARKETPLACE_API_URL) var_value="$APPS_MARKETPLACE_API_URL" ;;
    EXTENSIONS_API_URL) var_value="$EXTENSIONS_API_URL" ;;
    APPS_TUNNEL_URL_KEYWORDS) var_value="$APPS_TUNNEL_URL_KEYWORDS" ;;
    IS_CLOUD_INSTANCE) var_value="$IS_CLOUD_INSTANCE" ;;
    LOCALE_CODE) var_value="$LOCALE_CODE" ;;
    *) var_value="" ;;
  esac
  
  if [ -n "$var_value" ]; then
    echo "Setting $var_name to: $var_value"
    # Escape special characters in the value for sed (especially forward slashes)
    escaped_value=$(echo "$var_value" | sed 's/[[\.*^$()+?{|]/\\&/g' | sed 's|/|\\/|g')
    sed -i "s#$var_name: \".*\"#$var_name: \"$escaped_value\"#g" "$INDEX_BUNDLE_PATH"
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
