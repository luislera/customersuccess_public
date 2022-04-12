module.exports = async ({ github, context, solutionNamesString, githubRef }) => {
    console.log(solutionNamesString)

    await createCommitStatus(solutionNamesString, githubRef);

    async function createCommitStatus(solutionName, githubRef) {
        await github.rest.actions.createWorkflowDispatch({
            owner: context.repo.owner,
            repo: context.repo.repo,
            workflow_id: 'export-unpack-commit-solution.yml',
            ref: 'refs/heads/main',
            inputs: {
              solution_name: solutionName,
              environment_url: 'https://orgea394ded.crm.dynamics.com/',
              source_branch: 'main',
              branch_to_create: 'init2',
              commit_message: 'test'
            }
          })
    }
}