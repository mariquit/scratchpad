# Validating CloudFormation templates via GIT Hooks

My team uses a lot of CloudFormation templates.

This approach automates the validation of the CFN templates.

### Prerequisites

* AWS CLI installed and configured
* Linux or OSX (sorry Windows users.  It might work under cygwin but I've never tested it with cygwin)

### Deployment

Nothing to configure.  Just add a symlink to the file as git hook pre-commit.

Run the following shell command:
```
ln -s ~/git/scratchpad/aws_cloudformation/cfn-hook_pre-commit.sh ~/some_project/.git/hooks/pre-commit
```

The script works by calling the `aws cloudformation validate-template` command to validate the template.  If it fails, the commit is aborted.


## Built With

* [vi](https://en.wikipedia.org/wiki/Vi) - The editor I used for creating the scripts
