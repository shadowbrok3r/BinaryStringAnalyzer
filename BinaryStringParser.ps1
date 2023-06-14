# Load Mono.Cecil
Add-Type -Path "E:\Users\darkm\Desktop\BinaryStringAnalyzer\Mono.Cecil.dll"

# Load the assembly using Mono.Cecil
$assembly = [Mono.Cecil.AssemblyDefinition]::ReadAssembly("E:\Users\darkm\Desktop\BinaryStringAnalyzer\Crossgems\CrossGemsCM.dll")

# Define the strings you're looking for
$searchStrings = @("CrossGemsCM.Licensing", "CrossGems.Ui", "Fingerprint", "Cryptography")

# Loop over each type in the assembly
foreach ($type in $assembly.MainModule.Types) {
    $foundMatch = $false

    # Check if the type name contains any of the search strings
    foreach ($searchString in $searchStrings) {
        if ($type.FullName.Contains($searchString)) {
            # Print the type and its token ID
            Write-Host ("Type: " + $type.FullName + " Token: " + $type.MetadataToken).Replace($searchString, "`e[31m$searchString`e[0m")
            $foundMatch = $true
            break
        }
    }

    # If a match was found, print the methods of the type
    if ($foundMatch) {
        # Loop over each method in the type
        foreach ($method in $type.Methods) {
            # Skip methods with non-ASCII characters
            if ($method.Name -match "[^\x00-\x7F]") {
                continue
            }

            # Print the method name, its token ID, return type, and parameters
            Write-Host "`t`e[35mMethod:`e[0m $($method.Name) `e[35mToken:`e[0m $($method.MetadataToken)"
            Write-Host "`t`t`e[36mReturn type:`e[0m `t`t`e[32m$($method.ReturnType.FullName)`e[0m"
            
            foreach ($parameter in $method.Parameters) {
                Write-Host "`t`e[33mParameter:`e[0m $($parameter.ParameterType.FullName) $($parameter.Name)"
            }
        }
    }
}





<#


# Command Line Arguments
param (
    [Parameter(Mandatory=$true)]
    [string]$assemblyPath,
    [Parameter(Mandatory=$true)]
    [string[]]$stringsToSearch
)

# Load the assembly
$assembly = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($assemblyPath)

# Loop over each type in the assembly
foreach ($type in $assembly.MainModule.Types) {
    # Loop over each method in the type
    foreach ($method in $type.Methods) {
        # Check if the method is not empty
        if ($method.Body.Instructions.Count -ne 0) {
            # Check if the method name or the type name contains any of the search strings
            foreach ($str in $stringsToSearch) {
                if ($method.Name -match $str -or $type.FullName -match $str) {
                    Write-Host -ForegroundColor Green "Type: $($type.FullName)"
                    Write-Host -ForegroundColor Purple "`tMethod: $($method.Name)"
                    Write-Host -ForegroundColor Cyan "`t`tReturn Type: $($method.ReturnType)"
                    Write-Host -ForegroundColor Yellow "`t`tParameters: $($method.Parameters.Count)"
                }
            }
        }
    }
}





# Load Mono.Cecil
Add-Type -Path "Mono.Cecil.dll"

# Load the assembly using Mono.Cecil
$assembly = [Mono.Cecil.AssemblyDefinition]::ReadAssembly("RestSharp.dll")

# Loop over each type in the assembly
foreach ($type in $assembly.MainModule.Types) {
    Write-Host "Type: $($type.FullName)"

    # Loop over each method in the type
    foreach ($method in $type.Methods) {
        Write-Host "`tMethod: $($method.Name)"
    }
}

#>


<#
Example of reflection
#>

<#
# Load file into memory via reflection
$bin = [IO.File]::ReadAllBytes("C:\Program Files\CrossGems\CrossGemsCM.dll")
$ref = [Reflection.Assembly]::Load($bin)

# Set start and end IDs from dnSpy
$start = 0x0600022E
$end = 0x06000536

# Invoke each method ID and print results
for ($id = $start; $id -lt $end; $id++){
    $method = $ref.Modules[0].ResolveMethod($id)

    if ($method.IsStatic -and $method.GetParameters().Length -eq 0) {
        $decoded = $method.Invoke($null, $null)
        Write-Host $decoded
    }
}

#>





<#
Licensing
License

Type: CrossGemsCM.Licensing.Info.MachineInfo
	Method: get_ID
	Method: get_Platform
	Method: get_HostName
	Method: get_WinUsername
	Method: get_ValidationType
	Method: get_Name
	Method: get_Fingerprint
	Method: get_IpPublic
	Method: get_IpLocal
	Method: get_RequireHeartbeat
	Method: get_HeartbeatStatus
	Method: get_LastHeartbeat
	Method: get_NextHeartbeat
	Method: get_Created
	Method: get_Updated
	Method: get_UserId
	Method: .ctor
	Method: MillisecondsToNextHeartBeat
	Method: HearbeatIsExpired
	Method: GetExpiryDate
	Method: StaticIsExpired
	Method: IsExpired
	Method: GetMachineName

Type: CrossGemsCM.Licensing.Info.TokenInfo
	Method: get_ID
	Method: get_Token
	Method: get_Created
	Method: get_Expiry
	Method: get_Updated
	Method: get_TokenType
	Method: get_UserId
	Method: .ctor
	Method: HasExpired

Type: CrossGemsCM.Licensing.Info.LicenseInfo
	Method: get_Policy
	Method: get_Name
	Method: get_ProductId
	Method: get_UserId
	Method: get_ActiveMachines
	Method: get_PolicyId
	Method: get_Key
	Method: get_ID
	Method: get_Expiry
	Method: get_Pro
	Method: get_Nfr
	Method: get_DealerEmail
	Method: get_Comments
	Method: get_Symbols
	Method: get_Suspended
	Method: get_MaxMachines
	Method: get_VersionLimit
	Method: get_IsValid
	Method: get_Offline
	Method: _9K3HzagFehIRiCrcjoANJAHbETQ
	Method: .ctor
	Method: IsValidKey
	Method: GetPolicy
	Method: HasExpired
	Method: GetModernName

Type: CrossGemsCM.Licensing.Info.LicenseValidationType
Type: CrossGemsCM.Licensing.Info.LicensePolicy
Type: CrossGemsCM.Licensing.Info.Requisite
Type: CrossGemsCM.Licensing.Info.AccountInfo
	Method: add_OnLicenseValidated
	Method: remove_OnLicenseValidated
	Method: add_OnStatusUpdated
	Method: remove_OnStatusUpdated
	Method: get_Policy
	Method: _rmYasB2VHlh8mBNPuhno75CYISd
	Method: _HZaoazaIJp7UwkohOvFHSmVCEJi
	Method: get_UserName
	Method: _rcJJGav8BfJbwAv4ItSDac8CE7R
	Method: _KCOadsPHF5DKfLVlo4aM3Gfe2oJA
	Method: _US539tCdxZhQHFUu77Eb5E3t1SH
	Method: get_TokenInfo
	Method: _PSsGpUwXrgEenmpeG9c0VcCDvZm
	Method: get_LicenseInfo
	Method: _noT8bynchtjDrOfae891dDW95ul
	Method: get_MachineInfo
	Method: _rDouvIgAkjavcZ62jDsKnnaBlB1
	Method: get_ValidationType
	Method: _AEiIFOlqAn68rKXWv1vSYNGK57e
	Method: .cctor
	Method: PerformValidation
	Method: get_IsValid
	Method: _z8FCJfzzKkhDRSWetaLpkycBYSW
	Method: _bw8vr8OIonQfD7X8mxjS06dQnbc
	Method: _2ei5TzwscVbfOKWVWRRlHUpYGmN
	Method: LogoutRelease
	Method: GetLicenseTypeName
	Method: DeleteCurrentMachine
	Method: ModifyCredentials
	Method: WriteCredentials
	Method: Write
	Method: Read
	Method: DeleteStored
	Method: Clear

Type: CrossGemsCM.Licensing.Info.MachinePreview
	Method: get_ID
	Method: get_Platform
	Method: get_HostName
	Method: get_WinUsername
	Method: get_ValidationType
	Method: get_Name
	Method: get_Fingerprint
	Method: get_IpPublic
	Method: get_IpLocal
	Method: get_Country
	Method: get_City
	Method: get_RequireHeartbeat
	Method: get_HeartbeatStatus
	Method: get_LastHeartbeat
	Method: get_NextHeartbeat
	Method: get_Created

Type: CrossGemsCM.Licensing.Info.LicensePreview
	Method: get_Policy
	Method: get_Name
	Method: get_ProductId
	Method: get_UserId
	Method: get_ActiveMachines
	Method: get_PolicyId
	Method: get_Key
	Method: get_ID
	Method: get_Expiry
	Method: get_Pro
	Method: get_Nfr
	Method: get_DealerEmail
	Method: get_Comments
	Method: get_Symbols
	Method: get_Suspended
	Method: get_MaxMachines
	Method: get_VersionLimit
	Method: .ctor
	Method: get_IsValid
	Method: HasExpired
	Method: GetModernName
Type: CrossGemsCM.Licensing.ValidationError

Type: CrossGemsCM.Licensing.Api
	Method: add_UploadProgress
	Method: remove_UploadProgress
	Method: add_UploadError
	Method: remove_UploadError
	Method: add_UploadSuccess
	Method: remove_UploadSuccess
	Method: Init
	Method: _ncce2nZ9q5xDyQKedCDGiiHxYCgA
	Method: _BFHUCtmMN7ixPaj6R02FsPED9dk
	Method: _43rO02yPmkcSPXB8Cem20K9xqSg
	Method: _QBwbAsycOSOAXoCA4Sdpd3eDdPOb
	Method: _pJeuA1NmbAGVI1t92I3buveCzMI
	Method: _5islYX9y4uKA6sCXyn7Q79bkEAj
	Method: _CxAYS4LIQxPO9hdHNvPl9ktnSDE
	Method: _hnqB5on06qOfGupbMwfC8R428nW
	Method: _20plbxYcM0sdbIuXa6TslYwyWmO
	Method: _5xxmGjadS6za5bQHjWnFMmOuFvi
	Method: _ccAQpnoVsXVDMvJoYCUrkRNEZu
	Method: _yMy3PYSaDHV6rU3kAkcVTLFLxTL
	Method: _kxsyUApV1HHPIawxWgSaVBADXUg
	Method: _ApBegiJK6dRWLhm8EkMqlzt6Fan
	Method: _EW7Ztb4H10wUy7FPT1FpMEgmJMg
	Method: _e5YnGm2PT3ZUm3VlzlewWvIouXB
	Method: _fuwTsST6zAvcz8HnJilb0IHGxYN
	Method: CreateMachine
	Method: _TrW2kJRivDixReh0iYESnLGpAsA
	Method: _qrN56JkwyAldkqx7k88SRAvkeKO
	Method: GetMap
	Method: _AG89yV0bHsHivIra02BYNOfJJy7b
	Method: GetLatestVersionLink
	Method: GetLatestVersionLinkV2
	Method: GetWebInstallerLinkFromServer
	Method: GetWebInstallerLink
	Method: GetWebInstallerLinkV2
	Method: _r5S0T5lNQlouYg1cIGc1fTKD8Hf
	Method: _nUJJIfC4apesCHfZQ8Ba7iIYAog
	Method: GetErrors
	Method: GetValue
	Method: GetString
	Method: CheckBan
	Method: _5Clczvp5uTSJRjCqgpYjfNuvA1X
	Method: CancelUpload
	Method: UploadRelease
	Method: GetCurrentDeployedVersions
	Method: .cctor
#>