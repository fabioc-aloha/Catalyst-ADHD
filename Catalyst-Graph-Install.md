# Catalyst-Graph Installation Guide

A simple setup guide for the Catalyst cognitive architecture visualization system.

## 📁 Required Files

### Main Script
- `Catalyst-Graph.ps1` (place in root directory)

### Output Directory
- The script automatically creates `catalyst-graphs/` directory for generated diagrams

## 🚀 Quick Setup

### Prerequisites
- **Windows PowerShell 5.1+** or **PowerShell Core 7+**
- **Visual Studio Code** (recommended for viewing diagrams)

### One-Command Setup
```powershell
# Run from your project directory
.\Catalyst-Graph.ps1 -AutoOpen
```

## 📋 Setup Steps

### Step 1: PowerShell Execution Policy
```powershell
# Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 2: Install VS Code Mermaid Extension (Optional)
```powershell
# For diagram viewing in VS Code
code --install-extension bierner.markdown-mermaid
```

### Step 3: Run the Script
```powershell
# Generate your cognitive architecture diagram
.\Catalyst-Graph.ps1 -AutoOpen
```

*Note: The script automatically creates the `catalyst-graphs/` directory for output files.*

## 🎯 What You Get

- **Catalyst-Graph.ps1**: Main visualization script
- **catalyst-graphs/**: Generated diagram files
- **Beautiful Diagrams**: Three-layer cognitive architecture visualizations

## 🔧 Usage Options

```powershell
# Generate and auto-open diagram
.\Catalyst-Graph.ps1 -AutoOpen

# Generate diagram only
.\Catalyst-Graph.ps1
```

## 🛠️ Common Issues

**PowerShell Script Error:**
```powershell
# If you get "execution disabled" error:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Catalyst-Graph.ps1 -AutoOpen
```

**Script Not Found:**
```powershell
# Make sure you're in the right folder:
Test-Path ".\Catalyst-Graph.ps1"  # Should return True
```

**Diagram Not Showing:**
```powershell
# Install VS Code Mermaid extension:
code --install-extension bierner.markdown-mermaid
```

## 📊 Sample Output

When you run the script, you'll see:

```
🧠 Catalyst Memory & Synapse Chart Generator
==================================================
🔍 Phase 1: Discovering knowledge files...
   ✅ Found 67 files across 5 memory systems
🧠 Phase 2: Analyzing embedded synapses...
   ✅ Discovered 53 synapse connections
🎨 Phase 3: Generating Catalyst Memory Chart...
   ✅ Diagram saved to: .\catalyst-graphs\catalyst-overview-YYYYMMDD-HHMMSS.md
   📖 Opened in VS Code for preview
```

This creates a beautiful visual diagram of your cognitive architecture with:
- Three-layer structure showing memory systems and connections
- Curved lines connecting related components
- Color-coded sections for different types of knowledge

---

*Simple setup guide for Catalyst-Graph.ps1 visualization tool*
