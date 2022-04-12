function Run-Workflow ($githubRef, $solution_name, $environment_url, $source_branch, $branch_to_create, $commit_message) {
    echo "init Run-Workflow"
    gh workflow run export-unpack-commit-solution --ref $githubRef -f solution_name=$solution_name -f environment_url=$environment_url -f source_branch=$source_branch -f branch_to_create=$branch_to_create -f commit_message=$commit_message
    echo "sleep for 5 seconds"
    Start-Sleep -Seconds 5
    gh workflow view export-unpack-commit-solution
    echo "end Run-Workflow"
}