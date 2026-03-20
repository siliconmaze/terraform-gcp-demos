#!/bin/bash
# =============================================================================
# GCP Terraform Workspace Management Script
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <command> [environment]"
    echo ""
    echo "Commands:"
    echo "  list              List all workspaces"
    echo "  create <env>      Create a new workspace"
    echo "  select <env>      Switch to a workspace"
    echo "  delete <env>      Delete a workspace"
    echo "  show              Show current workspace"
}

list_workspaces() {
    echo -e "${GREEN}Available workspaces:${NC}"
    cd "$TERRAFORM_DIR"
    terraform workspace list
}

show_current() {
    cd "$TERRAFORM_DIR"
    echo -e "${YELLOW}Current workspace:${NC} $(terraform workspace show)"
}

create_workspace() {
    local env="$1"
    
    if [[ ! "$env" =~ ^(dev|staging|prod)$ ]]; then
        echo -e "${RED}Error: Environment must be dev, staging, or prod${NC}"
        exit 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    if terraform workspace list | grep -q "* $env"; then
        echo -e "${YELLOW}Workspace '$env' already exists${NC}"
        return
    fi
    
    echo -e "${GREEN}Creating workspace: $env${NC}"
    terraform workspace new "$env"
}

select_workspace() {
    local env="$1"
    
    cd "$TERRAFORM_DIR"
    
    if ! terraform workspace list | grep -q "  $env"; then
        echo -e "${RED}Error: Workspace '$env' does not exist${NC}"
        exit 1
    fi
    
    terraform workspace select "$env"
    echo -e "${GREEN}Switched to workspace: $env${NC}"
}

delete_workspace() {
    local env="$1"
    
    if [[ "$env" == "default" ]]; then
        echo -e "${RED}Error: Cannot delete the default workspace${NC}"
        exit 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    if ! terraform workspace list | grep -q "  $env"; then
        echo -e "${YELLOW}Workspace '$env' does not exist${NC}"
        return
    fi
    
    echo -e "${RED}Warning: This will delete the Terraform state for $env!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        terraform workspace select default
        terraform workspace delete "$env"
        echo -e "${GREEN}Deleted workspace: $env${NC}"
    fi
}

case "$1" in
    list) list_workspaces ;;
    show) show_current ;;
    create) create_workspace "$2" ;;
    select) select_workspace "$2" ;;
    delete) delete_workspace "$2" ;;
    *) usage ;;
esac
