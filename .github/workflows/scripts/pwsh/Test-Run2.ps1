function Run-Workflow ($githubRef, $solution_name) {
    echo "init Run-Workflow"
    gh workflow run export-unpack-commit-solution --ref $githubRef -f solution_name=$solution_name -f
    echo "sleep for 5 seconds"
    Start-Sleep -Seconds 5
    $cmdOutput = gh workflow view export-unpack-commit-solution | Out-String
    echo "cmdOutput : $cmdOutput" 
    echo "end Run-Workflow"
}
