# Define API Keys and Endpoints
$octopusAPIKey = 'YOUR_OCTOPUS_API_KEY'
$octopusUri = 'https://your-octopus-instance/api'
$azureDevOpsPAT = 'YOUR_AZURE_DEVOPS_PAT'
$azureDevOpsUri = 'https://dev.azure.com/your_organization'

# Headers for Octopus Deploy
$octopusHeaders = @{
    "X-Octopus-ApiKey" = $octopusAPIKey
}

# Headers for Azure DevOps
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($azureDevOpsPAT)"))
$azureDevOpsHeaders = @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

# Function to fetch projects from Octopus Deploy
function Get-OctopusProjects {
    $uri = "$octopusUri/projects"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $octopusHeaders
    return $response.Items
}

# Function to create a project in Azure DevOps
function Create-AzureDevOpsProject($projectName) {
    $uri = "$azureDevOpsUri/_apis/projects?api-version=6.0"
    $body = @{
        name = $projectName
        description = "Migrated from Octopus Deploy"
        visibility = "private"
        capabilities = @{
            versioncontrol = @{
                sourceControlType = "Git"
            }
            processTemplate = @{
                templateTypeId = "6b724908-ef14-45cf-84f8-768b5384da45" # Agile Process Template ID
            }
        }
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $azureDevOpsHeaders -Body $body
    return $response
}

# Example usage
$octopusProjects = Get-OctopusProjects
foreach ($project in $octopusProjects) {
    $result = Create-AzureDevOpsProject -projectName $project.Name
    Write-Output "Created project in Azure DevOps: $($result.name)"
}
