@{

RootModule = 'brickBOX.psm1'   # Script module or binary module file associated with this manifest.
ModuleVersion = '2.0.0'         # Version number of this module.
# CompatiblePSEditions = @()    # Supported PSEditions
GUID = '9d038cf3-b469-4b78-a235-46488538ae7c'  # ID used to uniquely identify this module

Author = 'Patrick Page Gehrig'
CompanyName = 'pageBOX.ch'
Copyright = '(c) 2024 Patrick Page Gehrig. All rights reserved.'

Description = 'A collection of powershell functions, put in a module to make scripting easier'

PowerShellVersion = '5.1'       # Minimum version of the PowerShell engine required by this module
# PowerShellHostName = 'ConsoleHost' # Name of the PowerShell host required by this module. $host.name
# PowerShellHostVersion = ''    # Minimum version of the PowerShell host required by this module
# DotNetFrameworkVersion = ''   # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''               # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ProcessorArchitecture = ''    # Processor architecture (None, X86, Amd64) required by this module

# RequiredModules = @()         # Modules that must be imported into the global environment prior to importing this module
# RequiredAssemblies = @()      # Assemblies that must be loaded prior to importing this module
# ScriptsToProcess = @()        # Script files (.ps1) that are run in the caller's environment prior to importing this module.
# TypesToProcess = @()          # Type files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()        # Format files (.ps1xml) to be loaded when importing this module
# NestedModules = @()           # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Test-Admin',
    'Start-Elevated',
    'Set-Secret',
    'Get-Secret',
    'Clear-Secret',
    'Set-IniContent',
    'Invoke-API'
)

CmdletsToExport = @()           # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
VariablesToExport = '*'         # Variables to export from this module
AliasesToExport = @()           # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
# DscResourcesToExport = @()    # DSC resources to export from this module
# ModuleList = @()              # List of all modules packaged with this module
# FileList = @()                # List of all files packaged with this module

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags = @()            # Tags applied to this module. These help with module discovery in online galleries.
        LicenseUri = 'https://github.com/pageBOX/brickBOX/raw/main/LICENSE'
        ProjectUri = 'https://github.com/pageBOX/brickBOX/'
        # IconUri = ''          # A URL to an icon representing this module.
        # ReleaseNotes = ''     # ReleaseNotes of this module
        # Prerelease = ''       # Prerelease string of this module
        # RequireLicenseAcceptance = $false # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # ExternalModuleDependencies = @()  # External dependent modules of this module
    }
}

# HelpInfoURI = ''              # HelpInfo URI of this module
# DefaultCommandPrefix = ''     # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.

}
