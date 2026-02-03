# Databricks CLI configuration and utilities

# Completion setup
fpath+=$(brew --prefix)/share/zsh/site-functions
autoload -Uz compinit && compinit

# Default profile
export DATABRICKS_CONFIG_PROFILE="DEFAULT"

# Databricks CLI aliases
alias dbx="databricks"
alias dbx-lake-prd="DATABRICKS_CONFIG_PROFILE=DEFAULT databricks"
alias dbx-lake-stg="DATABRICKS_CONFIG_PROFILE=lake-stg databricks"
alias dbx-ext-prd="DATABRICKS_CONFIG_PROFILE=external-prd databricks"
alias dbx-ext-stg="DATABRICKS_CONFIG_PROFILE=external-stg databricks"
alias dbx-analysis-prd="DATABRICKS_CONFIG_PROFILE=analysis-prd databricks"
alias dbx-analysis-stg="DATABRICKS_CONFIG_PROFILE=analysis-stg databricks"
alias dbx-terraform="DATABRICKS_CONFIG_PROFILE=terraform databricks"

# Show current profile
dbx-profile() {
  echo "Current Databricks profile: ${DATABRICKS_CONFIG_PROFILE:-DEFAULT}"
}

# Switch profile
dbx-switch() {
  if [ -z "$1" ]; then
    echo "Usage: dbx-switch <profile-name>"
    echo "Available profiles:"
    echo "  - DEFAULT (lake-prd)"
    echo "  - lake-stg"
    echo "  - external-prd"
    echo "  - external-stg"
    echo "  - analysis-prd"
    echo "  - analysis-stg"
    echo "  - terraform"
    return 1
  fi
  export DATABRICKS_CONFIG_PROFILE=$1
  echo "Switched to profile: $1"
}

# Auto-detect profile from DAB bundle directory
dbx-auto-profile() {
  local current_dir=$(pwd)

  if [[ "$current_dir" == *"/lake/ingest_stg"* ]]; then
    export DATABRICKS_CONFIG_PROFILE="lake-stg"
  elif [[ "$current_dir" == *"/lake/ingest"* ]]; then
    export DATABRICKS_CONFIG_PROFILE="DEFAULT"
  elif [[ "$current_dir" == *"/external/"*"_stg"* ]]; then
    export DATABRICKS_CONFIG_PROFILE="external-stg"
  elif [[ "$current_dir" == *"/external/"* ]]; then
    export DATABRICKS_CONFIG_PROFILE="external-prd"
  else
    echo "Warning: Could not determine appropriate profile for current directory"
    return 1
  fi

  echo "Auto-selected profile: $DATABRICKS_CONFIG_PROFILE"
}

# List DAB bundles
dbx-list-bundles() {
    echo "=== Lake Bundles ==="
    ls -1d ~/Projects/ivry-data-platform-migration/dab/lake/*/ 2>/dev/null | grep -v src

    echo -e "\n=== External Bundles ==="
    ls -1d ~/Projects/ivry-data-platform-migration/dab/external/*/ 2>/dev/null | grep -v src
}

# Check bundle status
dbx-bundle-status() {
    echo "Checking bundle status..."
    databricks bundle validate --target prod

    if [ $? -eq 0 ]; then
        echo "✅ Bundle is valid"

        # Show deployed resources
        echo -e "\nDeployed resources:"
        databricks bundle summary --target prod 2>/dev/null || echo "No deployment found"
    else
        echo "❌ Bundle validation failed"
    fi
}

# Watch job execution
dbx-watch-job() {
    if [ -z "$1" ]; then
        echo "Usage: dbx-watch-job <job-name>"
        return 1
    fi

    watch -n 5 "databricks jobs list | grep -A 5 '$1'"
}

# Show recent job runs
dbx-recent-runs() {
    databricks runs list --limit 10 --output json | \
    jq -r '.runs[] | "\(.run_id) | \(.run_name) | \(.state.life_cycle_state) | \(.start_time | strftime("%Y-%m-%d %H:%M"))"' | \
    column -t -s '|'
}
