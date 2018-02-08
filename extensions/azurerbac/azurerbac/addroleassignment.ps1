function SetAssigment{
    Param(
����    [parameter(Mandatory=$true)][string]$Role,
        [parameter(Mandatory=$true)][guid]$ObjectId,
        [parameter(Mandatory=$true)][string]$ResourceGroupName,
        [parameter(Mandatory=$true)][string]$BreakonException
����)
            
    Try{
	
		$ErrorActionPreference = "Stop";
			Write-Host "Setting new assigment for $Role and $ObjectId";
			New-AzureRmRoleAssignment  -ObjectId $ObjectId -RoleDefinitionName $Role -ResourceGroupName $ResourceGroupName


    }Catch{
         $ErrorMessage = $_.Exception.Message
         Write-Host $ErrorMessage -ForegroundColor Red
         if($BreakonException -eq "true"){
            throw $_
         }
    }

    Write-Host "Assignment done"
}

Write-Host "Setting RBAC for group: $resourceGroupName";

$items = $null

if($action -eq 'Users'){
    Write-Host "Setting RBAC for specific users";
    $items = $users.Split(",");
}elseif($action -eq 'Groups'){
    Write-Host "Setting RBAC for specific groups";
    $items = $groups.Split(",");
}

if($items -ne $null){
    foreach($item in $items){

        $adObject = $null

        if($action -eq 'Users'){
			Write-Host "Getting user $item";
            $adObject = Get-AzureRmADUser -UserPrincipalName $item
        }elseif($action -eq 'Groups'){
			Write-Host "Getting group $item";
            $adObject = Get-AzureRmADGroup -SearchString $item
        }

        if($adObject -ne $null){
            SetAssigment -Role $role -ObjectId $adObject.Id -ResourceGroupName $resourceGroupName -BreakonException $failonError                      
        }else{
            Write-Host "Can't find ad object: $item" -ForegroundColor Red
        }
    }
}

   