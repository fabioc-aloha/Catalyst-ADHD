# 🧠 Catalyst Memory & Synapse Chart Generator
# PowerShell Script for Cognitive Architecture Visualization

param(
    [string]$WorkspacePath = ".\",
    [string]$OutputPath = "catalyst-graphs",
    [string]$DiagramType = "overview",
    [switch]$AutoOpen,
    [switch]$WatchMode,
    [string]$Theme = "neural"
)

# Configuration
$Script:Config = @{
    FilePatterns = @{
        Core = @("copilot-instructions.md")
        Procedural = @(".github\instructions\*.instructions.md")
        Episodic = @(".github\prompts\*.prompt.md")
        Domain = @("domain-knowledge\**\*.md")
        Worldview = @("worldview-foundation\**\*.md")
    }
    SynapseRegex = '^-\s+(.+?)\s+\((\d+\.\d+),\s*(.+?),\s*(.+?)\)\s*-\s*"(.+?)"$'
    CreationDateColors = @{
        # Color coding by file age (newest to oldest)
        VeryNew = "#10B981"     # Emerald - Created today
        New = "#3B82F6"         # Blue - Created this week
        Recent = "#8B5CF6"      # Purple - Created this month
        Older = "#F59E0B"       # Amber - Created > 1 month
        Legacy = "#EF4444"      # Red - Created > 3 months
    }
    SynapseWeightStyles = @{
        # CSS classes for different connection strengths
        VeryHigh = "synapseVeryHigh"     # 0.95-1.0
        High = "synapseHigh"             # 0.85-0.94
        Medium = "synapseMedium"         # 0.70-0.84
        Low = "synapseLow"               # < 0.70
    }
    Themes = @{
        Default = @{
            Core = "#1E3A8A"
            Procedural = "#166534"
            Episodic = "#581C87"
            Domain = "#EA580C"
            Worldview = "#DC2626"
        }
        Dark = @{
            Core = "#3B82F6"
            Procedural = "#22C55E"
            Episodic = "#A855F7"
            Domain = "#FB923C"
            Worldview = "#F87171"
        }
    }
}

# Main execution function
function Start-NewbornVisualization {
    param(
        [string]$Type = "overview",
        [bool]$OpenAfterGeneration = $true
    )
    
Write-Host "🧠 Catalyst Memory & Synapse Chart Generator" -ForegroundColor Cyan
Write-Host ($("=" * 50)) -ForegroundColor Gray

    try {
        # Phase 1: Discovery
        Write-Host "🔍 Phase 1: Discovering knowledge files..." -ForegroundColor Yellow
        $knowledgeMap = Get-KnowledgeFiles -BasePath $WorkspacePath
        Write-Host "   ✅ Found $($knowledgeMap.TotalFiles) files across $($knowledgeMap.Systems.Count) memory systems" -ForegroundColor Green
        
        # Phase 2: Analysis
        Write-Host "🧠 Phase 2: Analyzing embedded synapses..." -ForegroundColor Yellow
        $synapseData = Get-EmbeddedSynapses -KnowledgeMap $knowledgeMap
        Write-Host "   ✅ Discovered $($synapseData.TotalConnections) synapse connections" -ForegroundColor Green
        
        # Phase 3: Generation
        Write-Host "🎨 Phase 3: Generating Catalyst Memory Chart..." -ForegroundColor Yellow
        $diagram = New-MermaidDiagram -Type $Type -KnowledgeMap $knowledgeMap -SynapseData $synapseData -Theme $Theme
        
        # Phase 4: Output
        $outputFile = Save-DiagramToFile -Diagram $diagram -Type $Type -OutputPath $OutputPath
        Write-Host "   ✅ Diagram saved to: $outputFile" -ForegroundColor Green
        
        # Phase 5: Integration
        if ($OpenAfterGeneration) {
            Open-DiagramInVSCode -FilePath $outputFile
        }
        
        # Generate health report
        $healthReport = New-CognitiveHealthReport -KnowledgeMap $knowledgeMap -SynapseData $synapseData
        Write-Host "`n📊 Cognitive Architecture Health:" -ForegroundColor Cyan
        Write-Host $healthReport -ForegroundColor White
        
        return @{
            Success = $true
            OutputFile = $outputFile
            HealthReport = $healthReport
            Statistics = @{
                TotalFiles = $knowledgeMap.TotalFiles
                TotalConnections = $synapseData.TotalConnections
                HighStrengthConnections = $synapseData.HighStrength.Count
            }
        }
        
    } catch {
        Write-Error "❌ Visualization generation failed: $($_.Exception.Message)"
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# File discovery function
function Get-KnowledgeFiles {
    param([string]$BasePath)
    
    $knowledgeMap = @{
        Systems = @{}
        TotalFiles = 0
        FilesByAge = @{}
    }
    
    foreach ($system in $Script:Config.FilePatterns.Keys) {
        $files = @()
        foreach ($pattern in $Script:Config.FilePatterns[$system]) {
            $fullPattern = Join-Path $BasePath $pattern
            $foundFiles = Get-ChildItem -Path $fullPattern -Recurse -ErrorAction SilentlyContinue
            $files += $foundFiles | ForEach-Object {
                $ageCategory = Get-FileAgeCategory -LastModified $_.LastWriteTime
                @{
                    Path = $_.FullName
                    RelativePath = $_.FullName.Replace($BasePath, "").TrimStart("\")
                    Name = $_.BaseName
                    Size = $_.Length
                    LastModified = $_.LastWriteTime
                    Type = $system
                    AgeCategory = $ageCategory
                    CreationRank = Get-CreationRank -LastModified $_.LastWriteTime
                }
            }
        }
        $knowledgeMap.Systems[$system] = $files
        $knowledgeMap.TotalFiles += $files.Count
    }
    
    # Stack rank all files by creation date
    $allFiles = @()
    foreach ($system in $knowledgeMap.Systems.Keys) {
        $allFiles += $knowledgeMap.Systems[$system]
    }
    $rankedFiles = $allFiles | Sort-Object LastModified -Descending
    for ($i = 0; $i -lt $rankedFiles.Count; $i++) {
        $rankedFiles[$i].StackRank = $i + 1
    }
    
    return $knowledgeMap
}

# Utility function to determine file age category
function Get-FileAgeCategory {
    param([DateTime]$LastModified)
    
    $now = Get-Date
    $daysSince = ($now - $LastModified).TotalDays
    
    if ($daysSince -le 1) { return "VeryNew" }
    elseif ($daysSince -le 7) { return "New" }
    elseif ($daysSince -le 30) { return "Recent" }
    elseif ($daysSince -le 90) { return "Older" }
    else { return "Legacy" }
}

# Utility function to get creation rank score
function Get-CreationRank {
    param([DateTime]$LastModified)
    
    # Convert to Unix timestamp for numeric ranking
    return [int][double]::Parse((Get-Date $LastModified -UFormat %s))
}

# Utility function to get synapse weight styling
function Get-SynapseWeightStyle {
    param([double]$Strength)
    
    if ($Strength -ge 0.95) { return $Script:Config.SynapseWeightStyles.VeryHigh }
    elseif ($Strength -ge 0.85) { return $Script:Config.SynapseWeightStyles.High }
    elseif ($Strength -ge 0.70) { return $Script:Config.SynapseWeightStyles.Medium }
    else { return $Script:Config.SynapseWeightStyles.Low }
}

# Utility function to get directional arrow
function Get-DirectionalArrow {
    param([string]$Direction, [double]$Strength)
    
    switch ($Direction.ToLower()) {
        "bidirectional" { return "<-->" }
        "forward" { return "-->" }
        "backward" { return "<--" }
        default { return "-->" }
    }
}

# Utility function to get synapse CSS class for styling
function Get-SynapseClass {
    param([double]$Strength)
    
    if ($Strength -ge 0.95) { return $Script:Config.SynapseWeightStyles.VeryHigh }
    elseif ($Strength -ge 0.85) { return $Script:Config.SynapseWeightStyles.High }
    elseif ($Strength -ge 0.70) { return $Script:Config.SynapseWeightStyles.Medium }
    else { return $Script:Config.SynapseWeightStyles.Low }
}

# Synapse extraction function
function Get-EmbeddedSynapses {
    param($KnowledgeMap)
    
    $allSynapses = @()
    
    foreach ($system in $KnowledgeMap.Systems.Keys) {
        foreach ($file in $KnowledgeMap.Systems[$system]) {
            if (Test-Path $file.Path) {
                $content = Get-Content $file.Path -Raw
                $synapses = Extract-SynapsesFromContent -Content $content -SourceFile $file
                $allSynapses += $synapses
            }
        }
    }
    
    # Categorize by strength
    $categorized = @{
        HighStrength = @($allSynapses | Where-Object { $_.Strength -ge 0.90 })
        MediumStrength = @($allSynapses | Where-Object { $_.Strength -ge 0.70 -and $_.Strength -lt 0.90 })
        WeakStrength = @($allSynapses | Where-Object { $_.Strength -lt 0.70 })
        TotalConnections = $allSynapses.Count
    }
    
    return $categorized
}

# Synapse parsing function
function Extract-SynapsesFromContent {
    param([string]$Content, $SourceFile)
    
    $synapses = @()
    
    # Find synapse section
    if ($Content -match '(?ms)^##\s+Synapses\s+\(Embedded\s+Connections\)$(.*?)(?=^##|\z)') {
        $synapseSection = $matches[1]
        
        # Parse individual synapse lines
        $synapseLines = $synapseSection -split "`n" | Where-Object { $_ -match '^-\s+' }
        
        foreach ($line in $synapseLines) {
            if ($line -match $Script:Config.SynapseRegex) {
                $synapses += @{
                    Source = $SourceFile.RelativePath
                    Target = $matches[1].Trim()
                    Strength = [double]$matches[2]
                    ConnectionType = $matches[3].Trim()
                    Direction = $matches[4].Trim()
                    Description = $matches[5].Trim()
                }
            }
        }
    }
    
    return $synapses
}

# Mermaid diagram generation
function New-MermaidDiagram {
    param(
        [string]$Type,
        $KnowledgeMap,
        $SynapseData,
        [string]$Theme = "default"
    )
    
    switch ($Type.ToLower()) {
        "overview" { return New-OverviewDiagram -KnowledgeMap $KnowledgeMap -SynapseData $SynapseData -Theme $Theme }
        "synapses" { return New-SynapseNetworkDiagram -SynapseData $SynapseData -Theme $Theme }
        "health" { return New-HealthDashboard -KnowledgeMap $KnowledgeMap -SynapseData $SynapseData -Theme $Theme }
        "load" { return New-CognitiveLoadDiagram -KnowledgeMap $KnowledgeMap -Theme $Theme }
        default { return New-OverviewDiagram -KnowledgeMap $KnowledgeMap -SynapseData $SynapseData -Theme $Theme }
    }
}

# Overview diagram generator
function New-OverviewDiagram {
    param($KnowledgeMap, $SynapseData, $Theme)
    
    $nodes = @()
    $connections = @()
    $subgraphs = @()
    
    # Layer 1: Catalyst Core Architecture (Left)
    $subgraphs += "    subgraph L1[Catalyst Core Architecture]"
    $subgraphs += "        direction TB"
    $subgraphs += "        MCM[Meta-Cognitive Monitor]"
    $subgraphs += "        WM[Working Memory]"
    $subgraphs += "        BL[Bootstrap Learning]"
    $subgraphs += "        MCM --> WM"
    $subgraphs += "        WM --> BL"
    $subgraphs += "    end"
    $subgraphs += ""
    
    # Layer 2: Memory Systems (Middle)
    $subgraphs += "    subgraph L2[Memory Systems]"
    $subgraphs += "        direction TB"
    $subgraphs += "        PM[Procedural Memory]"
    $subgraphs += "        EM[Episodic Memory]"
    $subgraphs += "        DK[Domain Knowledge]"
    $subgraphs += "        WF[Worldview Foundation]"
    $subgraphs += "    end"
    $subgraphs += ""
    
    # Layer 3: Memory Files (Right) - Enhanced with Color Coding
    $subgraphs += "    subgraph L3[Memory Files - Color Coded by Creation Date]"
    $subgraphs += "        direction TB"
    
    # Generate subgraphs for each memory system in Layer 3
    $systemConfigs = @{
        Procedural = @{ Icon = "🔧"; Title = "Procedural Memory Files" }
        Episodic = @{ Icon = "📖"; Title = "Episodic Memory Files" }
        Domain = @{ Icon = "🎯"; Title = "Domain Knowledge Files" }
        Worldview = @{ Icon = "🌍"; Title = "Worldview Foundation Files" }
    }
    
    $allNodes = @()
    foreach ($system in $KnowledgeMap.Systems.Keys) {
        if ($KnowledgeMap.Systems[$system].Count -gt 0 -and $system -ne "Core") {
            $config = $systemConfigs[$system]
            if ($config) {
                $systemNodes = @()
                
                # Sort files within system by stack rank (newest first)
                $sortedFiles = $KnowledgeMap.Systems[$system] | Sort-Object StackRank
                
                foreach ($file in $sortedFiles) {
                    $nodeId = Get-SanitizedNodeId -FilePath $file.RelativePath
                    $nodeLabel = Get-ShortNodeLabel -FilePath $file.RelativePath
                    $ageIcon = Get-AgeIcon -AgeCategory $file.AgeCategory
                    $rankDisplay = "#{0}" -f $file.StackRank
                    
                    $enhancedLabel = "$ageIcon $nodeLabel $rankDisplay"
                    $systemNodes += "            $nodeId[`"$enhancedLabel`"]"
                    
                    $allNodes += @{ 
                        Id = $nodeId
                        Label = $enhancedLabel
                        Type = $system
                        AgeCategory = $file.AgeCategory
                        StackRank = $file.StackRank
                        LastModified = $file.LastModified
                    }
                }
                
                $subgraphs += "        subgraph $system`_Files[$($config.Icon) $($config.Title)]"
                $subgraphs += $systemNodes
                $subgraphs += "        end"
            }
        }
    }
    
    $subgraphs += "    end"
    
    # Generate inter-layer connections
    $connections += "    L1 --> L2"
    $connections += "    L2 --> L3"
    $connections += ""
    
    # Generate connections between Layer 2 and Layer 3 subsystems
    $connections += "    PM --> Procedural_Files"
    $connections += "    EM --> Episodic_Files"
    $connections += "    DK --> Domain_Files"
    $connections += "    WF --> Worldview_Files"
    $connections += ""
    
    # Generate enhanced connections from synapse data with weight-proportional styling
    $synapseConnections = @()
    $linkStyles = @()
    $allSynapses = @()
    foreach ($category in @("HighStrength", "MediumStrength", "WeakStrength")) {
        $allSynapses += $SynapseData[$category]
    }
    
    # Sort synapses by strength (strongest first) for better visual hierarchy
    $sortedSynapses = $allSynapses | Sort-Object Strength -Descending
    
    # Count existing connections to get proper link indices
    $baseConnectionCount = 7 # L1->L2, L2->L3, PM->Procedural_Files, EM->Episodic_Files, DK->Domain_Files, WF->Worldview_Files, MCM->WM, WM->BL
    $linkIndex = $baseConnectionCount
    
    foreach ($synapse in $sortedSynapses) {
        $sourceId = Get-SanitizedNodeId -FilePath $synapse.Source
        $targetId = Get-SanitizedNodeId -FilePath $synapse.Target
        $arrow = Get-DirectionalArrow -Direction $synapse.Direction
        
        $connectionLine = "    $sourceId $arrow $targetId"
        $synapseConnections += $connectionLine
        
        # Generate linkStyle based on synapse strength
        $strokeWidth = if ($synapse.Strength -ge 0.95) { "6px" }
                      elseif ($synapse.Strength -ge 0.85) { "4px" }
                      elseif ($synapse.Strength -ge 0.70) { "3px" }
                      else { "1px" }
        
        $strokeColor = if ($synapse.Strength -ge 0.95) { "#FF0000" }
                      elseif ($synapse.Strength -ge 0.85) { "#FF6600" }
                      elseif ($synapse.Strength -ge 0.70) { "#FFAA00" }
                      else { "#CCCCCC" }
        
        $linkStyles += "    linkStyle $linkIndex stroke:$strokeColor,stroke-width:$strokeWidth"
        $linkIndex++
        
        # Add connection strength as a comment for debugging
        $synapseConnections += "    %% Synapse: $($synapse.Source) -> $($synapse.Target) (Strength: $($synapse.Strength), Type: $($synapse.ConnectionType))"
    }
    
    if ($synapseConnections.Count -gt 0) {
        $connections += ""
        $connections += "    %% === ENHANCED SYNAPSE NETWORK ==="
        $connections += $synapseConnections
    }
    
    # Generate enhanced styling with color coding by creation date
    $themeColors = $Script:Config.Themes[$Theme]
    $creationColors = $Script:Config.CreationDateColors
    
    $styling = @"
    
    %% === ENHANCED STYLING ===
    %% Memory System Colors
    classDef core fill:$($themeColors.Core),stroke:#3B82F6,stroke-width:2px,color:white
    classDef procedural fill:$($themeColors.Procedural),stroke:#22C55E,stroke-width:2px,color:white
    classDef episodic fill:$($themeColors.Episodic),stroke:#A855F7,stroke-width:2px,color:white
    classDef domain fill:$($themeColors.Domain),stroke:#FB923C,stroke-width:2px,color:white
    classDef worldview fill:$($themeColors.Worldview),stroke:#F87171,stroke-width:2px,color:white
    
    %% Creation Date Color Coding (Stack Ranked)
    classDef veryNew fill:$($creationColors.VeryNew),stroke:#059669,stroke-width:3px,color:white
    classDef new fill:$($creationColors.New),stroke:#2563EB,stroke-width:2px,color:white  
    classDef recent fill:$($creationColors.Recent),stroke:#7C3AED,stroke-width:2px,color:white
    classDef older fill:$($creationColors.Older),stroke:#D97706,stroke-width:2px,color:white
    classDef legacy fill:$($creationColors.Legacy),stroke:#DC2626,stroke-width:2px,color:white
"@

    # Apply creation date styling to nodes
    $nodeClassAssignments = @()
    foreach ($node in $allNodes) {
        $ageClass = $node.AgeCategory.ToLower()
        $nodeClassAssignments += "    class $($node.Id) $ageClass"
    }
    
    if ($nodeClassAssignments.Count -gt 0) {
        $styling += "`n`n    %% Node Age Classifications`n"
        $styling += $nodeClassAssignments -join "`n"
    }
    
    # Apply synapse weight styling to links
    if ($linkStyles.Count -gt 0) {
        $styling += "`n`n    %% Synapse Weight Link Styling`n"
        $styling += $linkStyles -join "`n"
    }
    
    # Combine all parts with enhanced legend
    $legend = @"
**Legend:**
- 🟢 **Very New** (≤1 day): Emerald green - Recently created files
- 🔵 **New** (≤1 week): Blue - Recently modified files  
- 🟣 **Recent** (≤1 month): Purple - Recently updated content
- 🟠 **Older** (≤3 months): Amber - Established content
- 🔴 **Legacy** (>3 months): Red - Foundational content

**Connection Weights:**
- **6px lines**: Very High strength (0.95-1.0) - Critical pathways (Red #FF0000)
- **4px lines**: High strength (0.85-0.94) - Important connections (Orange #FF6600)
- **3px lines**: Medium strength (0.70-0.84) - Standard connections (Amber #FFAA00)
- **1px lines**: Low strength (<0.70) - Weak or emerging connections (Gray #CCCCCC)

**Directional Arrows:**
- `-->` Forward connections - Unidirectional influence
- `<->` Bidirectional connections - Mutual influence  
- `<--` Backward connections - Reverse influence

**Stack Rankings:** Files numbered by creation order (#1 = newest, higher numbers = older)
"@

    $diagram = @"
# Catalyst Cognitive Architecture - Enhanced Memory & Synapse Network

**Generated on:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Total Files:** $($KnowledgeMap.TotalFiles) across $($KnowledgeMap.Systems.Keys.Count) memory systems  
**Total Connections:** $($SynapseData.TotalConnections) synapse pathways

This enhanced chart visualizes the Catalyst cognitive architecture with:
- **Color coding by creation date** - Stack ranked from newest (🟢) to oldest (🔴)
- **Weight-proportional connection lines** - Thickness indicates synapse strength
- **Directional arrows** - Shows uni/bidirectional influence patterns
- **Three-layer architecture** - Core → Memory Systems → Individual Files

$legend

## Enhanced Catalyst Memory Architecture Overview

``````mermaid
%%{init: {
  'flowchart': {
    'curve': 'cardinal',
    'useMaxWidth': true
  }
}}%%
graph LR
$($subgraphs -join "`n")

$($connections -join "`n")

$styling
``````
"@
    
    return $diagram
}

# Utility function to get age icon
function Get-AgeIcon {
    param([string]$AgeCategory)
    
    switch ($AgeCategory) {
        "VeryNew" { return "🟢" }
        "New" { return "🔵" }
        "Recent" { return "🟣" }
        "Older" { return "🟠" }
        "Legacy" { return "🔴" }
        default { return "⚪" }
    }
}

# Utility functions
function Get-SanitizedNodeId {
    param([string]$FilePath)
    # Use the filename as base for uniqueness
    $filename = Split-Path $FilePath -Leaf
    $sanitized = ($filename -replace '\.(instructions|prompt)\.md$', '' -replace '\.md$', '' -replace '[^a-zA-Z0-9_\-]', '_' -replace '__+', '_' -replace '^_|_$', '')
    # Ensure it starts with a letter and add a short hash for uniqueness
    if ($sanitized -match '^\d') { $sanitized = "file_$sanitized" }
    $hash = ($FilePath.GetHashCode() -band 0x7FFFFFFF).ToString().Substring(0,4)
    return "${sanitized}_$hash"
}

function Get-ShortNodeLabel {
    param([string]$FilePath)
    $basename = Split-Path $FilePath -Leaf
    return $basename -replace '\.(instructions|prompt)\.md$', '' -replace '\.md$', ''
}

function Save-DiagramToFile {
    param($Diagram, $Type, $OutputPath)
    
    $fullOutputPath = Join-Path $WorkspacePath $OutputPath
    if (-not (Test-Path $fullOutputPath)) {
        New-Item -Path $fullOutputPath -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $filename = "catalyst-$Type-$timestamp.md"
    $filePath = Join-Path $fullOutputPath $filename
    
    $Diagram | Out-File -FilePath $filePath -Encoding UTF8
    return $filePath
}

function Open-DiagramInVSCode {
    param([string]$FilePath)
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Start-Process "code" -ArgumentList "`"$FilePath`""
        Write-Host "   📖 Opened in VS Code for preview" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Install VS Code and Mermaid extension for best viewing experience" -ForegroundColor Yellow
    }
}

function New-CognitiveHealthReport {
    param($KnowledgeMap, $SynapseData)
    
    $totalFiles = $KnowledgeMap.TotalFiles
    $totalConnections = $SynapseData.TotalConnections
    $highStrengthConnections = $SynapseData.HighStrength.Count
    $connectivityRatio = if ($totalFiles -gt 0) { [math]::Round($totalConnections / $totalFiles, 2) } else { 0 }
    
    $health = @"
   📊 Files: $totalFiles across $($KnowledgeMap.Systems.Keys.Count) memory systems
   🔗 Connections: $totalConnections total ($highStrengthConnections high-strength)
   💪 Connectivity Ratio: $connectivityRatio connections per file
   🎯 Architecture Status: $(if ($connectivityRatio -gt 2) { "EXCELLENT" } elseif ($connectivityRatio -gt 1) { "GOOD" } else { "NEEDS_ATTENTION" })
"@
    
    return $health
}

# Watch mode for real-time updates
function Start-WatchMode {
    param([string]$Path, [string]$Type = "overview")
    
    Write-Host "👁️  Starting watch mode for real-time updates..." -ForegroundColor Cyan
    Write-Host "   Monitoring: $Path" -ForegroundColor Gray
    Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
    
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $Path
    $watcher.Filter = "*.md"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    
    $action = {
        Write-Host "`n🔄 File change detected: $($Event.SourceEventArgs.Name)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2  # Debounce
        Start-NewbornVisualization -Type $Type -OpenAfterGeneration $false
    }
    
    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
    Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action
    
    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        $watcher.Dispose()
        Get-EventSubscriber | Unregister-Event
    }
}

# Command interface for cognitive system integration
function Invoke-CognitiveVisualization {
    param(
        [string]$Command,
        [hashtable]$Parameters = @{}
    )
    
    switch ($Command.ToLower()) {
        "generate" { 
            return Start-NewbornVisualization @Parameters 
        }
        "health" { 
            $knowledgeMap = Get-KnowledgeFiles -BasePath $WorkspacePath
            $synapseData = Get-EmbeddedSynapses -KnowledgeMap $knowledgeMap
            return New-CognitiveHealthReport -KnowledgeMap $knowledgeMap -SynapseData $synapseData
        }
        "watch" { 
            Start-WatchMode -Path $WorkspacePath @Parameters 
        }
        "analyze" { 
            # Full analysis without generating diagrams
            $knowledgeMap = Get-KnowledgeFiles -BasePath $WorkspacePath
            $synapseData = Get-EmbeddedSynapses -KnowledgeMap $knowledgeMap
            return @{
                KnowledgeMap = $knowledgeMap
                SynapseData = $synapseData
                Health = New-CognitiveHealthReport -KnowledgeMap $knowledgeMap -SynapseData $synapseData
            }
        }
        default { 
            Write-Error "Unknown command: $Command. Available: generate, health, watch, analyze"
        }
    }
}

# Main execution based on parameters
if ($MyInvocation.InvocationName -ne '.') {
    if ($WatchMode) {
        Start-WatchMode -Path $WorkspacePath -Type $DiagramType
    } else {
        $result = Start-NewbornVisualization -Type $DiagramType -OpenAfterGeneration $AutoOpen
        if ($result.Success) {
            Write-Host "`n🎉 Catalyst Memory Chart completed successfully!" -ForegroundColor Green
            Write-Host "📁 Output: $($result.OutputFile)" -ForegroundColor White
        }
    }
}

# Functions are available when dot-sourced or called directly - no Export-ModuleMember needed for script files
