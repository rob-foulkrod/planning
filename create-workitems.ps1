# Azure DevOps Work Items Creation Script - Hybrid Data-Driven Approach
# This script creates Features, PBIs, and Tasks from JSON project data files
#
# ⚠️  AI-GENERATED CODE NOTICE ⚠️
# This script was created with the assistance of AI (GitHub Copilot).
# Please review, test, and validate the code thoroughly before using in production.
# Verify all functionality, security considerations, and error handling before deployment.
# =============================================================================

<#
.SYNOPSIS
    Creates Azure DevOps work items (Features, PBIs, Tasks) from JSON project configuration files.

.DESCRIPTION
    This script automates the creation of hierarchical work items in Azure DevOps by reading 
    project data from JSON files. It creates Features, Product Backlog Items (PBIs), and Tasks
    with proper parent-child relationships and custom field values.

    The script uses a two-tier configuration system:
    1. projects-config.json - Contains available project configurations and settings
    2. Individual project data files - Contains the actual work item structure

.PARAMETER Organization
    The Azure DevOps organization name (required).
    Example: "classroomdemos"

.PARAMETER Project
    The Azure DevOps project name where work items will be created (required).
    Example: "ProjectColdBrew"

.PARAMETER Project
    The Azure DevOps project name where work items will be created (required).
    Must match a projectName in projects-config.json.
    Available values: "cold-brew", "ecommerce", "cloudkitchen"

.PARAMETER ConfigPath
    Path to the projects configuration file (optional).
    Default: ".\project-data\projects-config.json"

.PARAMETER WhatIf
    Preview mode - shows what would be created without actually creating work items (optional).
    Useful for validation and testing.

.EXAMPLE
    .\create-workitems.ps1 -Organization "classroomdemos" -Project "ProjectColdBrew"
    Creates work items for the ProjectColdBrew project.

.EXAMPLE
    .\create-workitems.ps1 -Organization "classroomdemos" -Project "CloudKitchen"
    Creates work items for the CloudKitchen project.

.EXAMPLE
    .\create-workitems.ps1 -Organization "classroomdemos" -Project "ECommercePortal" -WhatIf
    Previews what would be created for the ECommercePortal project without actually creating items.

.NOTES
    Prerequisites:
    1. Install Azure DevOps CLI extension: az extension add --name azure-devops
    2. Login to Azure: az login
    3. Ensure you have permissions to create work items in the target project

    File Structure:
    - projects-config.json: Main configuration with available projects
    - project-data/*.json: Individual project data files with work item structures

.LINK
    Azure DevOps CLI: https://docs.microsoft.com/en-us/azure/devops/cli/
#>

# 
# Prerequisites:
# 1. Install Azure DevOps CLI extension: az extension add --name azure-devops
# 2. Login to Azure: az login
# 3. Configure your organization and project: 
#    az devops configure --defaults organization=https://dev.azure.com/YourOrg project=ProjectName

# Script Parameters with validation and help text
param(
    [Parameter(Mandatory=$false, HelpMessage="Show detailed help information and exit")]
    [switch]$Help = $false,
    
    [Parameter(Mandatory=$false, HelpMessage="Azure DevOps organization name (e.g., 'classroomdemos')")]
    [ValidateNotNullOrEmpty()]
    [string]$Organization,
    
    [Parameter(Mandatory=$false, HelpMessage="Azure DevOps project name where work items will be created")]
    [string]$Project,
    
    [Parameter(Mandatory=$false, HelpMessage="Path to projects configuration file")]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$ConfigPath = ".\project-data\projects-config.json",
    
    [Parameter(Mandatory=$false, HelpMessage="Preview mode - show what would be created without creating actual work items")]
    [switch]$WhatIf = $false
)

# Handle help request - show detailed help and exit without executing
if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# Validate required parameters when not showing help
if (-not $Organization) {
    Write-Host "❌ Error: Organization parameter is required" -ForegroundColor Red
    Write-Host "Use -Help for detailed usage information" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example: .\create-workitems.ps1 -Organization 'classroomdemos' -Project 'ProjectColdBrew'" -ForegroundColor Gray
    exit 1
}

if (-not $Project) {
    Write-Host "❌ Error: Project parameter is required" -ForegroundColor Red
    Write-Host "Use -Help for detailed usage information" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example: .\create-workitems.ps1 -Organization 'classroomdemos' -Project 'ProjectColdBrew'" -ForegroundColor Gray
    exit 1
}

# Function to create work item with error handling
<#
.SYNOPSIS
    Creates a single work item in Azure DevOps with proper error handling and field updates.

.DESCRIPTION
    This function creates a work item using the Azure CLI, then optionally adds parent relationships
    and updates custom fields like effort, business value, and remaining work.

.PARAMETER Title
    The title/name of the work item

.PARAMETER Type
    The work item type (Feature, Product Backlog Item, Task)

.PARAMETER Description
    Detailed description of the work item

.PARAMETER ParentId
    ID of the parent work item for hierarchical linking (optional)

.PARAMETER RemainingWork
    Estimated remaining work in hours (for Tasks)

.PARAMETER Effort
    Story points or effort estimation (for PBIs)

.PARAMETER BusinessValue
    Business value rating 1-5 (for PBIs)

.PARAMETER ProjectName
    Azure DevOps project name where the work item will be created

.PARAMETER Organization
    Azure DevOps organization name

.PARAMETER WhatIf
    Preview mode - returns a mock ID without creating actual work items

.RETURNS
    Returns the created work item ID or null if creation failed
#>
function Create-WorkItem {
    param(
        [string]$Title,
        [string]$Type,
        [string]$Description,
        [string]$ParentId = $null,
        [int]$RemainingWork = $null,
        [int]$Effort = $null,
        [int]$BusinessValue = $null,
        [string]$ProjectName,
        [string]$Organization,
        [switch]$WhatIf = $false
    )
    
    # In What-If mode, return a mock ID for testing without creating actual work items
    if ($WhatIf) {
        Write-Host "Would create $Type`: $Title" -ForegroundColor Cyan
        Write-Host "  Target Project: $ProjectName" -ForegroundColor Gray
        if ($ParentId) { Write-Host "  Parent: $ParentId" -ForegroundColor Gray }
        if ($RemainingWork) { Write-Host "  Remaining Work: $RemainingWork hours" -ForegroundColor Gray }
        if ($Effort) { Write-Host "  Effort: $Effort story points" -ForegroundColor Gray }
        if ($BusinessValue) { Write-Host "  Business Value: $BusinessValue" -ForegroundColor Gray }
        return "WHATIF-ID-$(Get-Random)"
    }
    
    # Build the Azure CLI command for work item creation
    $command = "az boards work-item create --title `"$Title`" --type `"$Type`" --description `"$Description`" --organization https://dev.azure.com/$Organization --project `"$ProjectName`""
    
    Write-Host "Creating $Type`: $Title (in project: $ProjectName)" -ForegroundColor Green
    
    try {
        # Execute the Azure CLI command and capture both output and errors
        $result = Invoke-Expression $command 2>&1
        
        # Check if the command failed by looking for actual error indicators
        # Only treat as error if we get actual error messages, not successful JSON responses
        if ($LASTEXITCODE -ne 0 -or ($result -match "ERROR|FATAL|command not found|az: command not found")) {
            Write-Host "❌ Failed to create work item: $Title" -ForegroundColor Red
            Write-Host "Error: $result" -ForegroundColor Red
            
            # Only terminate on Feature creation failures (critical infrastructure issues)
            # Allow PBI and Task failures to continue (might be temporary issues)
            if ($Type -eq "Feature") {
                Write-Host ""
                Write-Host "💥 CRITICAL ERROR: Cannot create Features. This indicates fundamental project access issues." -ForegroundColor Red
                Write-Host "Please verify:" -ForegroundColor Yellow
                Write-Host "  • Project name: '$ProjectName'" -ForegroundColor White
                Write-Host "  • Organization: '$Organization'" -ForegroundColor White
                Write-Host "  • You have access to create work items in this project" -ForegroundColor White
                Write-Host "  • You are logged in to Azure CLI (run 'az login')" -ForegroundColor White
                exit 1
            } else {
                Write-Host "  ⚠️ Continuing with remaining work items..." -ForegroundColor Yellow
                return $null
            }
        }
        
        # Parse the JSON response if successful
        $parsedResult = $result | ConvertFrom-Json
        Write-Host "Created work item ID: $($parsedResult.id)" -ForegroundColor Green
        
        # Add parent-child relationship if a parent ID is specified
        # Note: Work item IDs are unique across the organization, so no --project parameter needed
        if ($ParentId -and $ParentId -notlike "WHATIF*") {
            try {
                $parentCommand = "az boards work-item relation add --id $($parsedResult.id) --relation-type parent --target-id $ParentId --organization https://dev.azure.com/$Organization"
                Invoke-Expression $parentCommand | Out-Null
                Write-Host "  ✅ Linked to parent: $ParentId" -ForegroundColor Gray
            }
            catch {
                Write-Host "  ⚠️ Failed to link to parent: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        # Update custom fields (effort, business value, remaining work) if specified
        # Note: Work item IDs are unique across the organization, so no --project parameter needed
        if ($RemainingWork -or $Effort -or $BusinessValue) {
            try {
                $updateFields = @()
                if ($RemainingWork) { $updateFields += "Microsoft.VSTS.Scheduling.RemainingWork=$RemainingWork" }
                if ($Effort) { $updateFields += "Microsoft.VSTS.Scheduling.Effort=$Effort" }
                if ($BusinessValue) { $updateFields += "Microsoft.VSTS.Common.BusinessValue=$BusinessValue" }
                
                $fieldCommand = "az boards work-item update --id $($parsedResult.id) --fields $($updateFields -join ' ') --organization https://dev.azure.com/$Organization"
                Invoke-Expression $fieldCommand | Out-Null
                Write-Host "  ✅ Updated custom fields" -ForegroundColor Gray
            }
            catch {
                Write-Host "  ⚠️ Failed to update custom fields: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        return $parsedResult.id
    }
    catch {
        Write-Host "❌ Failed to create work item: $Title" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Only terminate on Feature creation failures (critical infrastructure issues)
        if ($Type -eq "Feature") {
            Write-Host ""
            Write-Host "💥 CRITICAL ERROR: Cannot create Features. Terminating script execution." -ForegroundColor Red
            Write-Host "This indicates fundamental project access or authentication issues." -ForegroundColor Yellow
            exit 1
        } else {
            Write-Host "  ⚠️ Continuing with remaining work items..." -ForegroundColor Yellow
            return $null
        }
    }
}

# Function to load and validate JSON configuration files
<#
.SYNOPSIS
    Loads project configuration and data files with validation and error handling.

.DESCRIPTION
    This function handles the complete loading process:
    1. Loads the main projects-config.json file
    2. Finds the project configuration by project name
    3. Validates the project configuration exists
    4. Loads the specific project data file
    5. Returns the validated configuration and data

.PARAMETER ConfigPath
    Path to the projects-config.json file

.PARAMETER ProjectName
    Azure DevOps project name where work items will be created (required)

.RETURNS
    Returns a hashtable with Config, ProjectConfig, ProjectData, and ProjectName
#>
function Load-ProjectData {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath,
        [Parameter(Mandatory=$true)]
        [string]$ProjectName
    )
    
    try {
        # Load and parse the main projects configuration file
        if (-not (Test-Path $ConfigPath)) {
            throw "Configuration file not found: $ConfigPath"
        }
        
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        Write-Host "✅ Loaded projects configuration" -ForegroundColor Green
        
        # Display which project is being used
        Write-Host "Using project: $ProjectName" -ForegroundColor Gray
        
        # Find the specified project in the available projects list
        $projectConfig = $config.availableProjects | Where-Object { $_.projectName -eq $ProjectName }
        if (-not $projectConfig) {
            Write-Host "Available projects in config:" -ForegroundColor Yellow
            $config.availableProjects | ForEach-Object { Write-Host "  - $($_.projectName): $($_.displayName)" -ForegroundColor Yellow }
            throw "Project '$ProjectName' not found in configuration. Available projects: $($config.availableProjects.projectName -join ', ')"
        }
        
        # Use the specified Azure DevOps project name
        Write-Host "Using specified project name: $ProjectName" -ForegroundColor Gray
        
        # Load and parse the specific project data file
        $dataFilePath = Join-Path (Split-Path $ConfigPath -Parent) $projectConfig.dataFile
        if (-not (Test-Path $dataFilePath)) {
            throw "Project data file not found: $dataFilePath"
        }
        
        $projectData = Get-Content $dataFilePath -Raw | ConvertFrom-Json
        Write-Host "✅ Loaded project data: $($projectConfig.displayName)" -ForegroundColor Green
        
        # Return all loaded configuration and data
        return @{
            Config = $config
            ProjectConfig = $projectConfig
            ProjectData = $projectData
            ProjectName = $ProjectName
        }
    }
    catch {
        Write-Host "❌ Failed to load project data: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Function to process project phases and create hierarchical work items
<#
.SYNOPSIS
    Processes all project phases and creates work items in hierarchical order.

.DESCRIPTION
    This function iterates through the project structure and creates work items in the correct order:
    1. Features (top-level, one per major project phase)
    2. Product Backlog Items (specific deliverables under each feature)
    3. Tasks (granular work items under each PBI)
    
    Each level is properly linked to its parent and custom fields are populated.

.PARAMETER ProjectData
    The loaded project data containing phases, features, PBIs, and tasks

.PARAMETER Config
    The configuration object containing work item type definitions

.PARAMETER ProjectName
    Azure DevOps project name where work items will be created

.PARAMETER Organization
    Azure DevOps organization name

.PARAMETER WhatIf
    Preview mode - shows what would be created without creating actual work items

.RETURNS
    Returns a summary object with creation statistics
#>
function Process-ProjectPhases {
    param(
        [object]$ProjectData,
        [object]$Config,
        [string]$ProjectName,
        [string]$Organization,
        [switch]$WhatIf = $false
    )
    
    # Initialize summary statistics for reporting
    $summary = @{
        FeaturesCreated = 0
        PBIsCreated = 0
        TasksCreated = 0
        TotalEstimatedHours = 0
    }
    
    # Process each project phase in order
    foreach ($phase in $ProjectData.phases) {
        Write-Host ""
        Write-Host "Processing Phase: $($phase.name) ($($phase.timeframe))" -ForegroundColor Magenta
        Write-Host "Description: $($phase.description)" -ForegroundColor Gray
        
        # Process each feature within the current phase
        foreach ($feature in $phase.features) {
            # Create the Feature work item (top-level)
            $featureId = Create-WorkItem -Title $feature.title -Type $Config.settings.workItemTypes.feature -Description $feature.description -ProjectName $ProjectName -Organization $Organization -WhatIf:$WhatIf
            if ($featureId) {
                $summary.FeaturesCreated++
                
                # Process each PBI under the current feature
                foreach ($pbi in $feature.pbis) {
                    # Create the Product Backlog Item (middle-level, linked to Feature)
                    $pbiId = Create-WorkItem -Title $pbi.title -Type $Config.settings.workItemTypes.pbi -Description $pbi.description -ParentId $featureId -Effort $pbi.effort -BusinessValue $pbi.businessValue -ProjectName $ProjectName -Organization $Organization -WhatIf:$WhatIf
                    if ($pbiId) {
                        $summary.PBIsCreated++
                        
                        # Process each task under the current PBI
                        foreach ($task in $pbi.tasks) {
                            # Create the Task work item (bottom-level, linked to PBI)
                            $taskId = Create-WorkItem -Title $task.title -Type $Config.settings.workItemTypes.task -Description $task.description -ParentId $pbiId -RemainingWork $task.remainingWork -ProjectName $ProjectName -Organization $Organization -WhatIf:$WhatIf
                            if ($taskId) {
                                $summary.TasksCreated++
                                # Accumulate total estimated hours for reporting
                                if ($task.remainingWork) {
                                    $summary.TotalEstimatedHours += $task.remainingWork
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return $summary
}

# ============================================================================= 
# MAIN SCRIPT EXECUTION
# =============================================================================
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Azure DevOps Work Items Creation Script" -ForegroundColor Cyan
Write-Host "Hybrid Data-Driven Approach" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "🔍 RUNNING IN WHAT-IF MODE - No actual work items will be created" -ForegroundColor Yellow
    Write-Host ""
}

# Load project data
Write-Host "📂 Loading project configuration and data..." -ForegroundColor Yellow
$data = Load-ProjectData -ConfigPath $ConfigPath -ProjectName $Project

# Display project information and configuration resolution
Write-Host ""
Write-Host "Project Information:" -ForegroundColor Cyan
Write-Host "  Name: $($data.ProjectData.projectMetadata.fullName)" -ForegroundColor White
Write-Host "  Description: $($data.ProjectData.projectMetadata.description)" -ForegroundColor White
Write-Host "  Phases: $($data.ProjectData.phases.Count)" -ForegroundColor White
Write-Host "  Organization: $Organization" -ForegroundColor White
Write-Host "  Azure DevOps Project: $($data.ProjectName)" -ForegroundColor White

# Show debug information about parameter resolution
Write-Host ""
Write-Host "🔍 DEBUG - Project Resolution:" -ForegroundColor Yellow
Write-Host "  Input Project Parameter: $Project" -ForegroundColor Gray
Write-Host "  Resolved Project Name: $($data.ProjectName)" -ForegroundColor Gray
Write-Host "  Will create work items in: $($data.ProjectName)" -ForegroundColor Gray

# Configure Azure DevOps CLI defaults (skip in What-If mode)
if (-not $WhatIf) {
    # Configure Azure DevOps defaults - use the project name from config
    Write-Host ""
    Write-Host "📋 Configuring Azure DevOps defaults..." -ForegroundColor Yellow
    Write-Host "Setting default project to: $($data.ProjectName)" -ForegroundColor Gray
    az devops configure --defaults organization=https://dev.azure.com/$Organization/ project=$($data.ProjectName)
}

# Process all project phases and create work items
Write-Host ""
Write-Host "🚀 Starting work item creation process..." -ForegroundColor Yellow

$summary = Process-ProjectPhases -ProjectData $data.ProjectData -Config $data.Config -ProjectName $data.ProjectName -Organization $Organization -WhatIf:$WhatIf

# ============================================================================= 
# RESULTS SUMMARY AND REPORTING
# =============================================================================
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Work Items Creation Summary" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "WHAT-IF MODE - No actual work items were created" -ForegroundColor Yellow
} else {
    Write-Host "✅ Successfully created work items!" -ForegroundColor Green
}

# Display creation statistics and summary
Write-Host ""
Write-Host "Work Item Summary:" -ForegroundColor Yellow
Write-Host "  🎯 Features: $($summary.FeaturesCreated)" -ForegroundColor White
Write-Host "  📝 Product Backlog Items: $($summary.PBIsCreated)" -ForegroundColor White
Write-Host "  ✅ Tasks: $($summary.TasksCreated)" -ForegroundColor White
Write-Host "  ⏱️ Total Estimated Hours: $($summary.TotalEstimatedHours)" -ForegroundColor White

# Calculate and display average hours per task if tasks were created
if ($summary.TasksCreated -gt 0) {
    $avgHours = [math]::Round($summary.TotalEstimatedHours / $summary.TasksCreated, 1)
    Write-Host "  📊 Average Hours per Task: $avgHours" -ForegroundColor White
}

# Provide direct link to Azure DevOps backlog for the created work items
Write-Host ""
Write-Host "� View Work Items in Azure DevOps:" -ForegroundColor Yellow
$backlogUrl = "https://dev.azure.com/$Organization/$($data.ProjectName)/_backlogs/backlog/$($data.ProjectName)%20Team/Backlog%20items"
Write-Host "   $backlogUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "� Next: Assign work items to sprints, team members, and begin planning!" -ForegroundColor White

# Show command to run for real if this was a What-If execution
if ($WhatIf) {
    Write-Host ""
    Write-Host "To create the work items for real, run the script without the -WhatIf parameter:" -ForegroundColor Cyan
    Write-Host "  .\create-workitems.ps1 -Organization '$Organization' -Project '$Project'" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎉 Script execution completed!" -ForegroundColor Green
