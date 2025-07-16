# ProjectColdBrew - Azure DevOps Work Items Creation Script
# This script creates Features, PBIs, and Tasks for the Cold Brew Recipe Calculator project
# 
# Prerequisites:
# 1. Install Azure DevOps CLI extension: az extension add --name azure-devops
# 2. Login to Azure: az login
# 3. Configure your organization and project: 
#    az devops configure --defaults organization=https://dev.azure.com/YourOrg project=ProjectColdBrew

param(
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    
    [Parameter(Mandatory=$true)]
    [string]$Project
)

# Function to create work item with error handling
function Create-WorkItem {
    param(
        [string]$Title,
        [string]$Type,
        [string]$Description,
        [string]$ParentId = $null
    )
    
    $command = "az boards work-item create --title `"$Title`" --type `"$Type`" --description `"$Description`""
    
    Write-Host "Creating $Type`: $Title" -ForegroundColor Green
    
    try {
        $result = Invoke-Expression $command | ConvertFrom-Json
        Write-Host "Created work item ID: $($result.id)" -ForegroundColor Green
        
        # Add parent relationship if specified (using separate command for reliability)
        if ($ParentId) {
            $relationCommand = "az boards work-item relation add --id $($result.id) --relation-type `"Parent`" --target-id $ParentId"
            try {
                Invoke-Expression $relationCommand | Out-Null
                Write-Host "Linked to parent work item ID: $ParentId" -ForegroundColor Cyan
            }
            catch {
                Write-Host "Failed to link to parent: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        return $result.id
    }
    catch {
        Write-Host "❌ Failed to create work item: $Title" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "📋 Configuring Azure DevOps defaults for $Organization and $Project" -ForegroundColor Yellow
az devops configure --defaults organization=https://dev.azure.com/$Organization/ project=$Project

Write-Host "=== $Project Work Items Creation ===" -ForegroundColor Cyan
Write-Host "Organization: $Organization" -ForegroundColor Yellow
Write-Host "Project: $Project" -ForegroundColor Yellow
Write-Host "Note: All work items will be created in the backlog without iteration assignments" -ForegroundColor Yellow
Write-Host ""

# Phase 0: DevOps Project Setup (Week 0)
Write-Host "Creating Phase 0 Features and PBIs..." -ForegroundColor Magenta

$phase0FeatureId = Create-WorkItem -Title "DevOps Project Setup" -Type "Feature" -Description "Establish project foundation including repository setup, CI/CD pipelines, development environment configuration, and initial project structure for the Cold Brew Recipe Calculator app."

if ($phase0FeatureId) {
    # PBI 0.1: Repository and Project Structure Setup
    $pbi0_1 = Create-WorkItem -Title "Repository and Project Structure Setup" -Type "Product Backlog Item" -Description "Create and configure source code repositories, establish project folder structure, and set up development environment standards." -ParentId $phase0FeatureId
    
    if ($pbi0_1) {
        Create-WorkItem -Title "Create main source code repository" -Type "Task" -Description "Set up Git repository with appropriate branching strategy and access controls" -ParentId $pbi0_1
        Create-WorkItem -Title "Establish project folder structure" -Type "Task" -Description "Create standardized folder structure for frontend, backend, documentation, and infrastructure code" -ParentId $pbi0_1
        Create-WorkItem -Title "Configure repository settings and permissions" -Type "Task" -Description "Set up branch protection rules, pull request requirements, and team access permissions" -ParentId $pbi0_1
        Create-WorkItem -Title "Create initial README and documentation structure" -Type "Task" -Description "Add project overview, setup instructions, and documentation templates" -ParentId $pbi0_1
        Create-WorkItem -Title "Set up development environment configuration" -Type "Task" -Description "Create development environment setup scripts and configuration files" -ParentId $pbi0_1
    }
    
    # PBI 0.2: Continuous Integration Setup
    $pbi0_2 = Create-WorkItem -Title "Continuous Integration Pipeline" -Type "Product Backlog Item" -Description "Implement automated build and testing pipeline to ensure code quality and catch issues early in the development process." -ParentId $phase0FeatureId
    
    if ($pbi0_2) {
        Create-WorkItem -Title "Configure build automation" -Type "Task" -Description "Set up automated builds triggered by code commits and pull requests" -ParentId $pbi0_2
        Create-WorkItem -Title "Implement automated testing pipeline" -Type "Task" -Description "Configure unit test execution and code coverage reporting in CI pipeline" -ParentId $pbi0_2
        Create-WorkItem -Title "Set up code quality checks" -Type "Task" -Description "Integrate linting, code analysis, and security scanning tools" -ParentId $pbi0_2
        Create-WorkItem -Title "Configure build notifications" -Type "Task" -Description "Set up notifications for build failures and success status reporting" -ParentId $pbi0_2
        Create-WorkItem -Title "Create build status badges and reporting" -Type "Task" -Description "Add build status visibility and reporting dashboards" -ParentId $pbi0_2
    }
    
    # PBI 0.3: Development Environment Deployment
    $pbi0_3 = Create-WorkItem -Title "Development Environment Deployment" -Type "Product Backlog Item" -Description "Set up initial deployment pipeline for development environment with basic CI/CD capabilities for early testing and validation." -ParentId $phase0FeatureId
    
    if ($pbi0_3) {
        Create-WorkItem -Title "Set up development hosting environment" -Type "Task" -Description "Configure cloud hosting resources for development environment deployment" -ParentId $pbi0_3
        Create-WorkItem -Title "Create basic deployment pipeline" -Type "Task" -Description "Implement automated deployment to development environment on successful builds" -ParentId $pbi0_3
        Create-WorkItem -Title "Configure environment variables and secrets" -Type "Task" -Description "Set up secure management of configuration and sensitive data for deployments" -ParentId $pbi0_3
        Create-WorkItem -Title "Implement deployment rollback capability" -Type "Task" -Description "Add ability to quickly rollback deployments if issues are detected" -ParentId $pbi0_3
        Create-WorkItem -Title "Set up deployment monitoring and health checks" -Type "Task" -Description "Implement basic monitoring to ensure deployment success and application health" -ParentId $pbi0_3
    }
    
    # PBI 0.4: Complete CI/CD Pipeline
    $pbi0_4 = Create-WorkItem -Title "Complete CI/CD Pipeline with Multi-Environment Support" -Type "Product Backlog Item" -Description "Extend CI/CD pipeline to support multiple environments (staging, production) with approval workflows and advanced deployment strategies." -ParentId $phase0FeatureId
    
    if ($pbi0_4) {
        Create-WorkItem -Title "Set up staging environment" -Type "Task" -Description "Configure staging environment that mirrors production for pre-release testing" -ParentId $pbi0_4
        Create-WorkItem -Title "Implement approval workflows" -Type "Task" -Description "Add manual approval gates for staging and production deployments" -ParentId $pbi0_4
        Create-WorkItem -Title "Configure production deployment pipeline" -Type "Task" -Description "Set up secure, automated deployment pipeline for production environment" -ParentId $pbi0_4
        Create-WorkItem -Title "Implement blue-green deployment strategy" -Type "Task" -Description "Add zero-downtime deployment capabilities with automatic failover" -ParentId $pbi0_4
        Create-WorkItem -Title "Set up comprehensive monitoring and alerting" -Type "Task" -Description "Implement full monitoring stack with alerts for all environments" -ParentId $pbi0_4
    }
}

# Phase 1: Core Calculator and Basic UI (Weeks 1-4)
Write-Host "Creating Phase 1 Features and PBIs..." -ForegroundColor Magenta

$phase1FeatureId = Create-WorkItem -Title "Core Calculator and Basic UI" -Type "Feature" -Description "Implement the core brewing calculator functionality and basic user interface for the Cold Brew Recipe Calculator app. This phase includes recipe calculations, basic UI components, and fundamental app architecture."

if ($phase1FeatureId) {
    # PBI 1.1: Recipe Calculation Engine
    $pbi1_1 = Create-WorkItem -Title "Recipe Calculation Engine" -Type "Product Backlog Item" -Description "Develop algorithms for calculating optimal coffee-to-water ratios, steeping times, and strength adjustments. Support multiple brewing methods and batch size scaling." -ParentId $phase1FeatureId
    
    if ($pbi1_1) {
        Create-WorkItem -Title "Research coffee brewing ratios and formulas" -Type "Task" -Description "Research industry standards for cold brew ratios, steeping times, and strength calculations" -ParentId $pbi1_1
        Create-WorkItem -Title "Design calculation algorithms" -Type "Task" -Description "Create mathematical formulas for ratio calculations and strength adjustments" -ParentId $pbi1_1
        Create-WorkItem -Title "Implement core calculation functions" -Type "Task" -Description "Code the core calculation logic with input validation" -ParentId $pbi1_1
        Create-WorkItem -Title "Add batch size scaling logic" -Type "Task" -Description "Implement functionality to scale recipes for different batch sizes" -ParentId $pbi1_1
        Create-WorkItem -Title "Create unit tests for calculations" -Type "Task" -Description "Write comprehensive unit tests for all calculation functions" -ParentId $pbi1_1
    }
    
    # PBI 1.2: Basic User Interface
    $pbi1_2 = Create-WorkItem -Title "Basic User Interface Components" -Type "Product Backlog Item" -Description "Create clean, intuitive UI components for recipe input, calculation display, and basic navigation. Focus on usability and responsive design." -ParentId $phase1FeatureId
    
    if ($pbi1_2) {
        Create-WorkItem -Title "Design UI wireframes and mockups" -Type "Task" -Description "Create wireframes for main calculator interface and navigation" -ParentId $pbi1_2
        Create-WorkItem -Title "Set up project structure and dependencies" -Type "Task" -Description "Initialize project with chosen framework and configure build tools" -ParentId $pbi1_2
        Create-WorkItem -Title "Implement main calculator input form" -Type "Task" -Description "Build form components for coffee amount, water volume, and strength selection" -ParentId $pbi1_2
        Create-WorkItem -Title "Create results display component" -Type "Task" -Description "Design and implement component to show calculated ratios and instructions" -ParentId $pbi1_2
        Create-WorkItem -Title "Add responsive design and basic styling" -Type "Task" -Description "Implement responsive CSS and ensure mobile compatibility" -ParentId $pbi1_2
    }
    
    # PBI 1.3: Brewing Timer System
    $pbi1_3 = Create-WorkItem -Title "Brewing Timer and Countdown" -Type "Product Backlog Item" -Description "Implement countdown timers for steeping periods with visual progress indicators and audio/visual alerts." -ParentId $phase1FeatureId
    
    if ($pbi1_3) {
        Create-WorkItem -Title "Design timer component interface" -Type "Task" -Description "Create UI design for timer display and controls" -ParentId $pbi1_3
        Create-WorkItem -Title "Implement countdown timer logic" -Type "Task" -Description "Build JavaScript timer functionality with start/pause/reset" -ParentId $pbi1_3
        Create-WorkItem -Title "Add visual progress indicators" -Type "Task" -Description "Create circular progress bars and time remaining displays" -ParentId $pbi1_3
        Create-WorkItem -Title "Implement timer alerts and notifications" -Type "Task" -Description "Add audio alerts and browser notifications for timer completion" -ParentId $pbi1_3
        Create-WorkItem -Title "Test timer accuracy and performance" -Type "Task" -Description "Validate timer precision and test on different devices" -ParentId $pbi1_3
    }
}

# Phase 2: User Accounts and Recipe Saving (Weeks 5-8)
Write-Host "Creating Phase 2 Features and PBIs..." -ForegroundColor Magenta

$phase2FeatureId = Create-WorkItem -Title "User Accounts and Recipe Saving" -Type "Feature" -Description "Implement user authentication, profile management, and recipe persistence functionality. Enable users to save, organize, and retrieve their favorite brewing recipes."

if ($phase2FeatureId) {
    # PBI 2.1: User Authentication System
    $pbi2_1 = Create-WorkItem -Title "User Authentication and Profiles" -Type "Product Backlog Item" -Description "Implement secure user registration, login, and profile management system with social authentication options." -ParentId $phase2FeatureId
    
    if ($pbi2_1) {
        Create-WorkItem -Title "Set up authentication service integration" -Type "Task" -Description "Choose and configure authentication provider (Firebase Auth, Auth0, etc.)" -ParentId $pbi2_1
        Create-WorkItem -Title "Create registration and login forms" -Type "Task" -Description "Build user registration and login UI components" -ParentId $pbi2_1
        Create-WorkItem -Title "Implement user profile management" -Type "Task" -Description "Create profile editing interface for user preferences" -ParentId $pbi2_1
        Create-WorkItem -Title "Add social authentication options" -Type "Task" -Description "Integrate Google and Facebook login options" -ParentId $pbi2_1
        Create-WorkItem -Title "Implement password reset functionality" -Type "Task" -Description "Add forgot password and reset password features" -ParentId $pbi2_1
    }
    
    # PBI 2.2: Recipe Persistence and Management
    $pbi2_2 = Create-WorkItem -Title "Recipe Save and Management System" -Type "Product Backlog Item" -Description "Enable users to save, name, organize, and manage their brewing recipes with categories and search functionality." -ParentId $phase2FeatureId
    
    if ($pbi2_2) {
        Create-WorkItem -Title "Design database schema for recipes" -Type "Task" -Description "Create data models for recipes, user preferences, and brewing history" -ParentId $pbi2_2
        Create-WorkItem -Title "Implement recipe saving functionality" -Type "Task" -Description "Add save recipe button and form for naming recipes" -ParentId $pbi2_2
        Create-WorkItem -Title "Create recipe library interface" -Type "Task" -Description "Build UI to display and manage saved recipes" -ParentId $pbi2_2
        Create-WorkItem -Title "Add recipe categorization and tagging" -Type "Task" -Description "Implement category system and custom tags for recipes" -ParentId $pbi2_2
        Create-WorkItem -Title "Implement recipe search and filtering" -Type "Task" -Description "Add search functionality and filters for recipe management" -ParentId $pbi2_2
    }
    
    # PBI 2.3: Brewing History Tracking
    $pbi2_3 = Create-WorkItem -Title "Brewing History and Analytics" -Type "Product Backlog Item" -Description "Track user brewing sessions, provide analytics on brewing patterns, and offer insights for improvement." -ParentId $phase2FeatureId
    
    if ($pbi2_3) {
        Create-WorkItem -Title "Design brewing session data model" -Type "Task" -Description "Create schema for tracking brewing sessions and outcomes" -ParentId $pbi2_3
        Create-WorkItem -Title "Implement session logging functionality" -Type "Task" -Description "Add automatic logging of completed brewing sessions" -ParentId $pbi2_3
        Create-WorkItem -Title "Create brewing history dashboard" -Type "Task" -Description "Build interface to view past brewing sessions and statistics" -ParentId $pbi2_3
        Create-WorkItem -Title "Add brewing success rating system" -Type "Task" -Description "Allow users to rate and review their brewing results" -ParentId $pbi2_3
        Create-WorkItem -Title "Generate brewing insights and recommendations" -Type "Task" -Description "Analyze patterns and suggest improvements" -ParentId $pbi2_3
    }
}

# Phase 3: Advanced Features and Polish (Weeks 9-12)
Write-Host "Creating Phase 3 Features and PBIs..." -ForegroundColor Magenta

$phase3FeatureId = Create-WorkItem -Title "Advanced Features and Polish" -Type "Feature" -Description "Implement advanced features including coffee bean database, community features, educational content, and application polish for production readiness."

if ($phase3FeatureId) {
    # PBI 3.1: Coffee Bean Database
    $pbi3_1 = Create-WorkItem -Title "Coffee Bean Database and Recommendations" -Type "Product Backlog Item" -Description "Build comprehensive database of coffee beans with flavor profiles, origin information, and brewing recommendations." -ParentId $phase3FeatureId
    
    if ($pbi3_1) {
        Create-WorkItem -Title "Research and compile coffee bean data" -Type "Task" -Description "Gather information on popular coffee beans and their characteristics" -ParentId $pbi3_1
        Create-WorkItem -Title "Design bean database schema" -Type "Task" -Description "Create data structure for bean information and flavor profiles" -ParentId $pbi3_1
        Create-WorkItem -Title "Implement bean selection interface" -Type "Task" -Description "Build UI for browsing and selecting coffee beans" -ParentId $pbi3_1
        Create-WorkItem -Title "Add flavor profile matching system" -Type "Task" -Description "Create algorithm to match beans with desired flavor profiles" -ParentId $pbi3_1
        Create-WorkItem -Title "Integrate bean data with calculations" -Type "Task" -Description "Adjust brewing recommendations based on selected bean type" -ParentId $pbi3_1
    }
    
    # PBI 3.2: Community Features
    $pbi3_2 = Create-WorkItem -Title "Recipe Sharing and Community Platform" -Type "Product Backlog Item" -Description "Enable users to share recipes, rate others' recipes, and participate in a community-driven brewing platform." -ParentId $phase3FeatureId
    
    if ($pbi3_2) {
        Create-WorkItem -Title "Design recipe sharing data model" -Type "Task" -Description "Create schema for public recipes and user interactions" -ParentId $pbi3_2
        Create-WorkItem -Title "Implement recipe publishing feature" -Type "Task" -Description "Add functionality to make recipes public and shareable" -ParentId $pbi3_2
        Create-WorkItem -Title "Create community recipe browser" -Type "Task" -Description "Build interface to discover and browse community recipes" -ParentId $pbi3_2
        Create-WorkItem -Title "Add rating and review system" -Type "Task" -Description "Implement star ratings and text reviews for recipes" -ParentId $pbi3_2
        Create-WorkItem -Title "Implement recipe import functionality" -Type "Task" -Description "Allow users to import and save community recipes" -ParentId $pbi3_2
    }
    
    # PBI 3.3: Educational Content and Guides
    $pbi3_3 = Create-WorkItem -Title "Educational Content and Brewing Guides" -Type "Product Backlog Item" -Description "Provide comprehensive educational content including brewing techniques, coffee science, and step-by-step guides for beginners." -ParentId $phase3FeatureId
    
    if ($pbi3_3) {
        Create-WorkItem -Title "Create brewing technique content" -Type "Task" -Description "Write guides for different cold brew methods and techniques" -ParentId $pbi3_3
        Create-WorkItem -Title "Design educational content interface" -Type "Task" -Description "Create UI for displaying tips, guides, and educational content" -ParentId $pbi3_3
        Create-WorkItem -Title "Add interactive brewing tutorials" -Type "Task" -Description "Implement step-by-step guided brewing experiences" -ParentId $pbi3_3
        Create-WorkItem -Title "Create grind size guide with visuals" -Type "Task" -Description "Build visual guide for coffee grind sizes and equipment" -ParentId $pbi3_3
        Create-WorkItem -Title "Add coffee science explanations" -Type "Task" -Description "Include educational content about extraction science and brewing principles" -ParentId $pbi3_3
    }
}

# Phase 4: Testing, Deployment, and Launch (Weeks 13-16)
Write-Host "Creating Phase 4 Features and PBIs..." -ForegroundColor Magenta

$phase4FeatureId = Create-WorkItem -Title "Phase 4: Testing, Deployment, and Launch" -Type "Feature" -Description "Comprehensive testing, performance optimization, deployment preparation, and launch activities for the Cold Brew Recipe Calculator app."

if ($phase4FeatureId) {
    # PBI 4.1: Quality Assurance and Testing
    $pbi4_1 = Create-WorkItem -Title "Comprehensive Testing and Quality Assurance" -Type "Product Backlog Item" -Description "Conduct thorough testing including unit tests, integration tests, user acceptance testing, and performance testing across all platforms." -ParentId $phase4FeatureId
    
    if ($pbi4_1) {
        Create-WorkItem -Title "Complete unit test coverage" -Type "Task" -Description "Ensure 90%+ unit test coverage for all core functionality" -ParentId $pbi4_1
        Create-WorkItem -Title "Perform integration testing" -Type "Task" -Description "Test API integrations and database operations" -ParentId $pbi4_1
        Create-WorkItem -Title "Conduct cross-browser testing" -Type "Task" -Description "Test application across major browsers and devices" -ParentId $pbi4_1
        Create-WorkItem -Title "Execute user acceptance testing" -Type "Task" -Description "Conduct UAT with target users and stakeholders" -ParentId $pbi4_1
        Create-WorkItem -Title "Performance testing and optimization" -Type "Task" -Description "Test load times, responsiveness, and optimize performance" -ParentId $pbi4_1
    }
    
    # PBI 4.2: Deployment and Infrastructure
    $pbi4_2 = Create-WorkItem -Title "Production Deployment and Infrastructure Setup" -Type "Product Backlog Item" -Description "Set up production infrastructure, deployment pipelines, monitoring, and ensure scalability and security for the live application." -ParentId $phase4FeatureId
    
    if ($pbi4_2) {
        Create-WorkItem -Title "Set up production hosting environment" -Type "Task" -Description "Configure cloud hosting and production database" -ParentId $pbi4_2
        Create-WorkItem -Title "Implement CI/CD deployment pipeline" -Type "Task" -Description "Set up automated build and deployment processes" -ParentId $pbi4_2
        Create-WorkItem -Title "Configure monitoring and logging" -Type "Task" -Description "Implement application monitoring and error tracking" -ParentId $pbi4_2
        Create-WorkItem -Title "Security audit and hardening" -Type "Task" -Description "Conduct security review and implement best practices" -ParentId $pbi4_2
        Create-WorkItem -Title "Set up backup and disaster recovery" -Type "Task" -Description "Implement data backup strategies and recovery procedures" -ParentId $pbi4_2
    }
    
    # PBI 4.3: Launch Preparation and Marketing
    $pbi4_3 = Create-WorkItem -Title "Launch Preparation and Go-to-Market" -Type "Product Backlog Item" -Description "Prepare for application launch including app store submissions, marketing materials, documentation, and user onboarding." -ParentId $phase4FeatureId
    
    if ($pbi4_3) {
        Create-WorkItem -Title "Create app store listings and assets" -Type "Task" -Description "Prepare app store descriptions, screenshots, and promotional materials" -ParentId $pbi4_3
        Create-WorkItem -Title "Develop user onboarding flow" -Type "Task" -Description "Create guided tour and tutorial for new users" -ParentId $pbi4_3
        Create-WorkItem -Title "Write user documentation and help content" -Type "Task" -Description "Create comprehensive help documentation and FAQs" -ParentId $pbi4_3
        Create-WorkItem -Title "Implement analytics and user tracking" -Type "Task" -Description "Set up user analytics and conversion tracking" -ParentId $pbi4_3
        Create-WorkItem -Title "Execute soft launch and gather feedback" -Type "Task" -Description "Conduct limited release to gather initial user feedback" -ParentId $pbi4_3
    }
}

Write-Host ""
Write-Host "=== Work Items Creation Complete ===" -ForegroundColor Green
Write-Host "✅ Created Features for all 4 project phases" -ForegroundColor Green
Write-Host "✅ Created PBIs (going to backlog without area assignments)" -ForegroundColor Green
Write-Host "✅ Created Tasks assigned to default iteration" -ForegroundColor Green
Write-Host ""
Write-Host "Work Item Summary:" -ForegroundColor Yellow
Write-Host "  � 4 Features (one per project phase)" -ForegroundColor White
Write-Host "  📝 12 Product Backlog Items (2-week scope each)" -ForegroundColor White
Write-Host "  ✅ 60 Tasks (half-day scope each)" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review created work items in Azure DevOps" -ForegroundColor White
Write-Host "2. Move PBIs from backlog to appropriate sprints" -ForegroundColor White
Write-Host "3. Assign work items to team members" -ForegroundColor White
Write-Host "4. Add story points and effort estimates" -ForegroundColor White
Write-Host "5. Set up area paths if needed and assign work items" -ForegroundColor White
Write-Host "6. Begin sprint planning for Phase 1" -ForegroundColor White
