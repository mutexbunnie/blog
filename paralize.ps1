$hostlist=Get-Content 'c:\hosts.txt'



foreach ($line in $hostlist)
{
    
	$jobs=Get-Job| where {$_.State -eq 'Running' }|Measure-Object -line
        $jobNr=$jobs.Lines
	echo "There are $jobNr jobs"
	while ($jobs.Lines -gt 15) 
	{
		echo "There are $jobNr jobs, waiting..."
		Start-Sleep -s 5
		Get-Job| where {$_.State -ne 'Running' }| % { Remove-Job $_.Id }
		$jobs=Get-Job| where {$_.State -ne 'Completed' }|Measure-Object -line
		$jobNr=$jobs.Lines
	}
	
	echo $line
	Start-Job { C:\DumpsecRep\Group.bat @args } -ArgumentList $line
	
}

while ($jobs.Lines -gt 1) 
	{
		Get-Job| where {$_.State -ne 'Running' }| % { Remove-Job $_.Id }
		$jobs=Get-Job| where {$_.State -ne 'Completed' }|Measure-Object -line
		$jobNr=$jobs.Lines
		echo "There are $jobNr jobs left, waiting..."
		Start-Sleep -s 10
		
	}
 
