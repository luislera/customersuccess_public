function Run-Workflow ($githubRef, $solution_name, $environment_url, $source_branch, $branch_to_create, $commit_message) {
    gh workflow run export-unpack-commit-solution --ref $githubRef -f solution_name=$solution_name -f environment_url=$environment_url -f source_branch=$source_branch -f branch_to_create=$branch_to_create -f commit_message=$commit_message

    echo "pipeline queued for $solution_name"
    gh workflow view export-unpack-commit-solution
}