function Invoke-Traceroute{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]$Destination,

        [Parameter(Mandatory=$false)]
        [int]$MaxTTL=16,

        [Parameter(Mandatory=$false)]
        [bool]$Fragmentation=$false,

        [Parameter(Mandatory=$false)]
        [bool]$VerboseOutput=$true,

        [Parameter(Mandatory=$false)]
        [int]$Timeout=5000
    )

    $ping = new-object System.Net.NetworkInformation.Ping
    $success = [System.Net.NetworkInformation.IPStatus]::Success
    $results = @()

    if($VerboseOutput){Write-Host "Tracing to $Destination"}
    for ($i=1; $i -le $MaxTTL; $i++) {
        $popt = new-object System.Net.NetworkInformation.PingOptions($i, $Fragmentation)   
        $reply = $ping.Send($Destination, $Timeout, [System.Text.Encoding]::Default.GetBytes("MESSAGE"), $popt)
        $addr = $reply.Address

        try{$dns = [System.Net.Dns]::GetHostByAddress($addr)}
        catch{$dns = "-"}

        $name = $dns.HostName

        $obj = New-Object -TypeName PSObject
        $obj | Add-Member -MemberType NoteProperty -Name hop -Value $i
        $obj | Add-Member -MemberType NoteProperty -Name address -Value $addr
        $obj | Add-Member -MemberType NoteProperty -Name dns_name -Value $name
        $obj | Add-Member -MemberType NoteProperty -Name latency -Value $reply.RoundTripTime

        if($VerboseOutput){Write-Host "Hop: $i`t= $addr`t($name)"}
        $results += $obj
