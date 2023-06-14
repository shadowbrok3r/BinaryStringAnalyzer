function FindPotentialDecryptionMethods($methods)
{
    $potentialDecryptionMethods = @()

    foreach($method in $methods)
    {
        # Skip methods without a body
        if(-not $method.HasBody) { continue }

        # Look for methods with two parameters, regardless of their types
        if($method.Parameters.Count -eq 2)
        {
            $potentialDecryptionMethods += $method
            continue
        }

        # Look for methods that take a string and return a string, regardless of the number of parameters
        if($method.Parameters | Where-Object { $_.Type.FullName -eq "System.String" } -and $method.ReturnType.FullName -eq "System.String")
        {
            $potentialDecryptionMethods += $method
            continue
        }

        # Look for methods that contain certain IL instructions, like call, ldstr, etc.
        if($method.Body.Instructions | Where-Object { $_.OpCode.Name -like "call" -or $_.OpCode.Name -like "ldstr" })
        {
            $potentialDecryptionMethods += $method
            continue
        }

        # Look for methods that contain exception handling code
        if($method.Body.ExceptionHandlers.Count -gt 0)
        {
            $potentialDecryptionMethods += $method
            continue
        }
    }

    return $potentialDecryptionMethods
}


function GetStateString($instr)
{
    if($instr.OpCode.Name -like "call")
    {
        $global:methodsToRemove += $instr.Operand
        return ($moduleRefl.ResolveMethod($instr.Operand.MDToken.ToInt32())).Invoke($null, $null)
    }
    if($instr.OpCode.Name -like "ldstr")
    {
        return $instr.Operand
    }
    return $null   
}

[System.Reflection.Assembly]::LoadFile("E:\Users\darkm\Desktop\BinaryStringAnalyzer\dnlib.dll") | Out-Null
$dot2Patch = "E:\Users\darkm\Desktop\Crossgems\CrossGemsCM.dll"
$patchedDot = $dot2Patch + "_mod.exe"

$moduleRefl = [System.Reflection.Assembly]::LoadFile($dot2Patch).modules
$moduleDefMD = [dnlib.DotNet.ModuleDefMD]::Load($dot2Patch)

#Write-Host $moduleDefMD
#Write-Host $moduleRefl

$methods = $moduleDefMD.GetTypes().ForEach{$_.Methods}
$decryptionMethod = FindStringDecryptionMethod -methods $methods
$global:methodsToRemove = @($decryptionMethod)

# string decryption
if(-not $decryptionMethod){Write-Host "Something went wrong, string decryption method was not found!!!" -ForegroundColor Red; Exit}
foreach($method in $methods)
{
    if(-not $method.HasBody){continue}
    foreach($instr in $method.MethodBody.Instructions.ToArray())
    {
        if($instr.OpCode.Name -like "call" -and $instr.Operand -eq $decryptionMethod)
        {
            $indexDecryptionMethodInstr = $method.MethodBody.Instructions.IndexOf($instr)
            $intInstr = $method.MethodBody.Instructions[$indexDecryptionMethodInstr-1]
            $decryptionMethod2 = $method.MethodBody.Instructions[$indexDecryptionMethodInstr-2]

            $stateStr1 = GetStateString -instr $method.MethodBody.Instructions[$indexDecryptionMethodInstr-4]
            $stateStr2 = GetStateString -instr $method.MethodBody.Instructions[$indexDecryptionMethodInstr-3]
            if(-not $stateStr1 -or -not $stateStr2){Write-Host "Something went wrong, cannot find all arguments!!!" -ForegroundColor Red; continue}
            $stateStr3 = ($moduleRefl.ResolveMethod($decryptionMethod2.Operand.MDToken.ToInt32())).Invoke($null, @($stateStr1, $stateStr2))
            $decryptedString = ($moduleRefl.ResolveMethod($instr.Operand.MDToken.ToInt32())).Invoke($null, @($stateStr3, $intInstr.Operand))
            $global:methodsToRemove += $decryptionMethod2.Operand
            # We cant patch the instruction this way as it is a target of branch in 1 method (this way will not refresh the branch target - result in exception on writing)
            # $patchInst = [dnlib.DotNet.Emit.Instruction]::Create([dnlib.DotNet.Emit.OpCodes]::Ldstr, $decryptedString)
            # $method.MethodBody.Instructions.Insert($indexDecryptionMethodInstr-4, $patchInst)
            # $method.MethodBody.Instructions[$indexDecryptionMethodInstr-4] = $patchInst

            # workaround to avoid patching of branch target (this way will refresh the branch target)
            $method.MethodBody.Instructions[$indexDecryptionMethodInstr-4].Opcode = [dnlib.DotNet.Emit.OpCodes]::Ldstr
            $method.MethodBody.Instructions[$indexDecryptionMethodInstr-4].Operand = $decryptedString

            $method.MethodBody.Instructions.RemoveRange($indexDecryptionMethodInstr-3, 4)
        }
    }
    $method.MethodBody.UpdateInstructionOffsets() | Out-Null
}

# function inlining of dummy methods containing only ldstr and ret
foreach($method in $methods)
{
    if(-not $method.HasBody){continue}
    foreach($instr in $method.MethodBody.Instructions.ToArray())
    {
        if(-not ($instr.OpCode.Name -like "call" -and $instr.Operand.IsMethod)){continue}
        if($instr.Operand.MethodBody.Instructions.Count -eq 2 -and $instr.Operand.MethodBody.Instructions[0].OpCode.Name -like "ldstr" -and $instr.Operand.MethodBody.Instructions[1].OpCode.Name -like "ret")
        {
            $strToInline = $instr.Operand.MethodBody.Instructions[0].Operand
            $global:methodsToRemove += $instr.Operand
            $instrIndex = $method.MethodBody.Instructions.IndexOf($instr)
            $method.MethodBody.Instructions[$instrIndex].Opcode = [dnlib.DotNet.Emit.OpCodes]::Ldstr
            $method.MethodBody.Instructions[$instrIndex].Operand = $strToInline
        }
    }
    $method.MethodBody.UpdateInstructionOffsets() | Out-Null
}

foreach($method in ($global:methodsToRemove | Sort-Object -Property MDToken -Unique))
{
    $method.DeclaringType.Remove($method)
}
$moduleWriterOptions = [dnlib.DotNet.Writer.ModuleWriterOptions]::new($moduleDefMD)
$moduleWriterOptions.MetadataOptions.Flags = $moduleWriterOptions.MetadataOptions.Flags -bor [dnlib.DotNet.Writer.MetadataFlags]::KeepOldMaxStack
# to ignore exception during writing - could be good to write even if some exception thrown
# $moduleWriterOptions.Logger = [dnlib.DotNet.DummyLogger]::NoThrowInstance
$moduleDefMD.Write($patchedDot, $moduleWriterOptions)