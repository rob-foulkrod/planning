# Azure DevOps Work Items Creation Script

## Overview

The `create-workitems.ps1` script automates the creation of Azure DevOps work items from JSON project configuration files. This PowerShell script creates a complete hierarchical structure of Features, Product Backlog Items (PBIs), and Tasks with proper parent-child relationships and custom field values.

## Key Features

- **JSON-Driven Configuration**: Uses structured JSON files to define project phases, features, and tasks
- **Multi-Project Support**: Supports multiple project configurations through a centralized configuration system
- **Hierarchical Work Item Creation**: Automatically creates Features → PBIs → Tasks with proper linking
- **What-If Preview Mode**: Preview exactly what will be created before making changes
- **Custom Field Population**: Automatically sets effort points, business value, and remaining work hours
- **Robust Error Handling**: Comprehensive error handling with detailed progress logging
- **Real-Time Feedback**: Live progress updates and detailed completion summary

## Prerequisites

1. **Azure DevOps CLI**: Install the Azure DevOps extension
   ```powershell
   az extension add --name azure-devops
   ```

2. **Authentication**: Login to Azure
   ```powershell
   az login
   ```

3. **Project Files**: Ensure your project data files exist in the `project-data` folder

## Usage

### Basic Usage

```powershell
# Create work items for the Cold Brew project
.\create-workitems.ps1 -Organization "classroomdemos" -Project "ProjectColdBrew"
```

### Specify Different Project

```powershell
# Create work items for the CloudKitchen project
.\create-workitems.ps1 -Organization "classroomdemos" -Project "CloudKitchen"
```

### What-If Mode (Preview)

```powershell
# Preview what would be created without actually creating items
.\create-workitems.ps1 -Organization "classroomdemos" -Project "ECommercePortal" -WhatIf
```

### Custom Configuration Path

```powershell
# Use a different configuration file
.\create-workitems.ps1 -Organization "classroomdemos" -Project "ProjectColdBrew" -ConfigPath ".\custom-config.json"
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `Organization` | Yes | - | Azure DevOps organization name |
| `Project` | Yes | - | Azure DevOps project name (must match a projectName in config) |
| `ConfigPath` | No | ".\project-data\projects-config.json" | Path to projects configuration file |
| `WhatIf` | No | false | Preview mode - don't create actual work items |

## How It Works

The script follows a structured approach to work item creation:

1. **Configuration Loading**: Reads the main configuration file (`projects-config.json`) to understand available projects
2. **Project Selection**: Identifies which project data to use based on the `-Project` parameter
3. **Data Validation**: Loads and validates the selected project's JSON data file
4. **Hierarchical Creation**: Creates work items in the correct order:
   - **Features** (top-level work items for major project phases)
   - **Product Backlog Items** (specific deliverables under each feature)
   - **Tasks** (granular work items under each PBI)
5. **Relationship Linking**: Automatically establishes parent-child relationships
6. **Field Population**: Sets custom fields like effort points, business value, and remaining work
7. **Summary Reporting**: Provides detailed creation statistics and next steps

## Available Projects

The script includes pre-configured projects ready for immediate use:

- **ProjectColdBrew**: Cold Brew Recipe Calculator (Medium complexity, 16 weeks)
- **ECommercePortal**: E-Commerce Learning Portal (High complexity, 14 weeks)  
- **CloudKitchen**: CloudKitchen Food Delivery Platform (Very High complexity, 14 weeks)

## Output

### What-If Mode Example
```
🔍 RUNNING IN WHAT-IF MODE - No actual work items will be created

Would create Feature: DevOps Foundation and Infrastructure Setup
  Target Project: ProjectColdBrew
Would create Product Backlog Item: Repository Setup and Project Structure
  Target Project: ProjectColdBrew
  Parent: WHATIF-ID-123456
  Effort: 8 story points
  Business Value: 5
Would create Task: Create microservices repository structure
  Target Project: ProjectColdBrew
  Parent: WHATIF-ID-789012
  Remaining Work: 6 hours
```

### Live Creation Example
```
Creating Feature: DevOps Foundation and Infrastructure Setup (in project: ProjectColdBrew)
Created work item ID: 42

Creating Product Backlog Item: Repository Setup and Project Structure (in project: ProjectColdBrew)
Created work item ID: 43
  ✅ Linked to parent: 42
  ✅ Updated custom fields

Creating Task: Create microservices repository structure (in project: ProjectColdBrew)
Created work item ID: 44
  ✅ Linked to parent: 43
  ✅ Updated custom fields
```

### Summary Report
```
========================================
Work Items Creation Summary
========================================
✅ Successfully created work items!

Work Item Summary:
  🎯 Features: 4
  📝 Product Backlog Items: 12
  ✅ Tasks: 60
  ⏱️ Total Estimated Hours: 340
  📊 Average Hours per Task: 5.7

Next Steps:
1. 🔍 Review created work items in Azure DevOps
2. 📅 Assign PBIs to appropriate sprints/iterations
3. 👥 Assign work items to team members
4. 🎯 Verify story points and effort estimates
5. 📍 Set up area paths if needed
6. 🏃‍♂️ Begin sprint planning and execution
```

## Script Capabilities

### Work Item Management
- **Automated Hierarchy Creation**: Creates Features, PBIs, and Tasks in the correct hierarchical structure
- **Parent-Child Linking**: Automatically establishes relationships between work items
- **Custom Field Population**: Sets Scrum-specific fields including effort points, business value, and remaining work hours
- **Project Targeting**: Ensures all work items are created in the correct Azure DevOps project

### Data Management
- **JSON Configuration System**: Uses structured JSON files for easy project definition and modification
- **Multi-Project Support**: Single script can handle multiple project templates (instructors can switch between different demo scenarios)
- **Flexible Project Selection**: Choose projects via command-line parameters or configuration defaults
- **Validation and Error Handling**: Comprehensive validation of configuration files and data integrity

### User Experience
- **What-If Preview Mode**: See exactly what will be created before executing
- **Real-Time Progress Tracking**: Live updates during creation process
- **Detailed Summary Reports**: Comprehensive statistics and next-step guidance
- **Robust Error Recovery**: Continues processing even if individual items fail

## Extending the Script

### Adding New Project Templates

1. **Create Project Data File**: Create a new JSON file following the established template structure
2. **Update Configuration**: Add your project to `projects-config.json`
3. **Test with What-If**: Validate your configuration using preview mode
4. **Execute**: Run the script to create your work items

Example configuration entry:
```json
{
  "template": "my-project",
  "projectName": "MyProject", 
  "displayName": "My Awesome Project",
  "dataFile": "my-project.json",
  "description": "Description of my project",
  "projectType": "Web Application",
  "estimatedDuration": "12 weeks", 
  "complexity": "Medium"
}
```

### Project Data Structure

Each project data file contains:
- **Project Metadata**: Basic information about the project
- **Phases**: High-level project phases with timeframes
- **Features**: Major functionality areas within each phase
- **PBIs**: Specific deliverable items under each feature
- **Tasks**: Granular work items with time estimates

## Troubleshooting

### Common Issues

1. **"Project not found in configuration"**
   - Check that your Template matches a template in projects-config.json
   - Verify the configuration file path is correct

2. **"Project data file not found"**
   - Ensure the data file exists in the project-data folder
   - Check the file name matches what's in the configuration

3. **"Failed to create work item"**
   - Verify you're logged into Azure CLI (`az login`)
   - Check that your organization and project names are correct
   - Ensure you have permissions to create work items

4. **"Failed to link to parent"** 
   - This is usually a permissions issue
   - The work item is still created, just not linked

### Tips

- Use `-WhatIf` first to preview and validate your data
- Start with a small test project to verify everything works
- Check Azure DevOps permissions if you encounter creation failures
- Review the JSON data files for any syntax errors

## AI Integration and Automation

The script is designed to work seamlessly with AI-generated project data. Using structured JSON templates, AI can generate complete project definitions that work immediately with this script.

### AI-Generated Project Workflow

1. **Template-Based Generation**: AI uses `project-template.json` to create structured project data
2. **Automatic Validation**: The script validates AI-generated data for completeness and accuracy
3. **Immediate Deployment**: Generated projects can be deployed to Azure DevOps without manual intervention

Example AI integration:
```powershell
# After AI generates a new project data file, simply run:
.\create-workitems.ps1 -Organization "your-org" -Project "your-project" -Template "ai-generated-project" -WhatIf
```

This approach enables rapid project setup for classroom environments, training scenarios, and prototype development.
