function Export-Unpack-Commit ($githubRef, $workflow_name, $solution_name, $environment_url, $source_branch, $branch_to_create, $commit_message) {
    gh workflow run $workflow_name --ref $githubRef -f solution_name=$solution_name -f environment_url=$environment_url -f source_branch=$source_branch -f branch_to_create=$branch_to_create -f commit_message=$commit_message

    Do
    {
        Start-Sleep -Seconds 10
        $cmdOutput = gh workflow view $workflow_name | Out-String
        $firstLine = ($cmdOutput -split '\n')[5]
        $status = ($firstLine -split '	')[0]
        echo "$workflow_name status: $status" 
    } While ($status -ne "completed")
}
function Sync-Unmanaged ($githubRef, $workflow_name, $from_branch, $to_branch) {
    gh workflow run $workflow_name --ref $githubRef -f from_branch=$from_branch -f to_branch=$to_branch

    Do
    {
        Start-Sleep -Seconds 10
        $cmdOutput = gh workflow view $workflow_name | Out-String
        $firstLine = ($cmdOutput -split '\n')[5]
        $status = ($firstLine -split '	')[0]
        echo "$workflow_name status: $status" 
    } While ($status -ne "completed")
}