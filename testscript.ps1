#Define the URL from which to download the MD5 hash file.
$Md5Url = "https://en-download-portal-cdn.azureedge.net/swstore/syngo.share/VA30C/syngo.share_VA30C.core_RH7.iso?sv=2021-10-04&st=2023-09-14T11%3A20%3A00Z&se=2023-12-31T12%3A20%3A00Z&sr=b&sp=r&sig=ZtuSsycYcYLiXZrkIqinePV%2BJnZAkpwhEOqcwKye9I4%3D" 

#Define the expected MD5 hash value from the downloaded package
$ExpectedHash = "C304F1428C8C882A45CFC97D9C44F44D" 

#Define the folder where results will be saved
$OutputFolder = "C:\temp\DownloadResult\" 

$outputFile = "C:\temp\syngo.share_VA30C.core_RH7.iso" 

#Define the name of the package being downloaded
$packageName = "syngo.share_VA30C.core_RH7.iso" 

#Define the URl of the package being downloaded
$URLName = "https://en-download-portal-cdn.azureedge.net/swstore/syngo.share/VA30C/syngo.share_VA30C.core_RH7.iso" 

#Check if the output folder exists, and create it if not
if (-not (Test-Path -Path $OutputFolder)) { 
    New-Item -Path $OutputFolder -ItemType Directory 
} 

#Initialize counters for successful and failed downloads
$successfulDownloads = 0 
$failedDownloads = 0 

#Start try-catch block for error handling
try { 
    $utcTimestampStart = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss") 
    Write-Output "UTC Timestamp (Start): $utcTimestampStart" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
    
    Write-Output "Using this URL for download: $URLName" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
    
    #loop for download attempts
    for ($i = 1; $i -le 5; $i++) { 
        Write-Output "Download attempt $i" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
        
        #Get local and UTC timestamps, and log them
        $localTimestamp = Get-Date -Format "yyyy-MM-dd HH-mm-ss" 
        $utcTimestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH-mm-ss") 
        Write-Output "Download $i - Local Time: $localTimestamp UTC Time: $utcTimestamp" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
        
        #Start nested try-catch block for download and verification
        try { 
            $outputFileName = "$OutputFolder\Download_$i-$utcTimestamp.txt" 
            $utcTimestampCurlStart = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss") 
            Write-Output "UTC Timestamp (Curl Start): $utcTimestampCurlStart" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
            
            # Use curl to download the content of the .md5 file and log its output
            & 'C:\Windows\System32\curl.exe' $Md5Url '-o' $outputFile 2>&1 | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
            
            $utcTimestampCurlEnd = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss") 
            Write-Output "UTC Timestamp (Curl End): $utcTimestampCurlEnd" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
            
            #Check if calculated hash matches the expected hash
            $md5hash = Get-FileHash -Algorithm md5 $outputFile 
            
            if ($ExpectedHash -eq $md5Hash.Hash) { 
                $result = "Hash Verified: Yes`r`n" 
                $result += "Expected Hash: $ExpectedHash`r`n" 
                $result += "Calculated Hash: $($md5Hash.hash)`r`n" 
                $successfulDownloads++ 
                $result += "Package Name: $packageName`r`n" 
                Remove-Item $outputFile 
            } else { 
                $result = "Hash Verified: No`r`n" 
                $result += "Expected Hash: 
                $ExpectedHash`r`n" 
                $result += "Calculated Hash: $($md5Hash.hash)`r`n" 
                $failedDownloads++ 
            } 
            
            #Log the result
            $result | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
            Write-Output "Download $i saved in CombinedLog.txt" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
            Write-Output $result | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
        } catch { 
            $errorMessage = "Error occurred during download: $($_.Exception.Message)" 
            Write-Output "Status: Failed`r`n$errorMessage" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append $failedDownloads++ 
        } 
    } 

} catch { 
            $errorMessage = "Error occurred: $($_.Exception.Message)" 
            Write-Output "Status: Failed`r`n$errorMessage" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
        } 
        $utcTimestampEnd = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss") 
        Write-Output "UTC Timestamp (End): $utcTimestampEnd" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
        Write-Output "Successful downloads: $successfulDownloads" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 
        Write-Output "Failed downloads: $failedDownloads" | Tee-Object -FilePath "$OutputFolder\CombinedLog.txt" -Append 