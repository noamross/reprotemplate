# repro-template




## Workflow and Reproducibility

<details>
<summary>Click to Expand</summary>

### Workflow: `{targets}` and R functions

This template uses `{targets}` as the main organizing workflow.  The `_targets.R`
file defines the steps of the project workflow, and functions for those steps
should be stored in files in the `R/` directory. 

`{targets}` has a [great manual and introduction]. The {tflow} and `{fnmate}`
packages by Miles McBain contain shortcuts and RStudio Add-Ins that help with
this workflow. 

[great manual and introduction]: https://books.ropensci.org/targets/

### `renv` and packages

This template uses `renv` to manage package versions.  In general, all the
packages should be listed in `packages.R`.  The settings in the `.Rprofile`
file will ensure that your package lockfile (`renv.lock`) is updated whenver
you install a new packages, or running `renv::snapshot()` periodically will
update the lockfile by scanning your R packages.

If you find your packages have conflicting names in their namespaces, you should
use the `{conflicted}` package to manage this.  The last part of the `.Rprofile`
file can be modified to resolve package conflicts.

### Makefile

The `Makefile` defines common tasks that can be run from the command line.
Type `make help` to get a printed list of commands. The RStudio "Build"
pane is set to use the Makefile, so the first command in the Makefile
(`make target`) and the `make clean` command are available via buttons and
keyboard shortcuts.

### Docker

This repository uses a Docker image to allow for reproducibility across platforms.
The image is defined in `Dockerfile`. For the most part it can be left alone. It
installs the R packages needed based on your `renv.lock` file.  However, you may
opt to change the base Dockerfile (by default `rocker/geospatial:4.1.0`) to a 
different R version a different version or configuration available from the 
[Rocker Project](https://github.com/rocker-org/rocker-versioned2), or add additional system
dependencies.

Note that if you change the R version to one older than the most current,
by changing the Dockerfile, you will want to change your `renv.lock` file, as
well, so the following section matches the version of R you are using.

```
  "R": {
    "Version": "4.1.0",
    "Repositories": [
      {
        "Name": "CRAN",
        "URL": "https://packagemanager.rstudio.com/all/latest"
      }
    ],
  ...
```

### GitHub Actions

The template is set up to use GitHub Actions build the Docker environment, 
run your code, print diagnostics and save the contents of the
`outputs` folder as build artifacts.

#### Cacheing 

The project options make aggressive use of cacheing in various contexts to speed
up build times locally and online.  Docker image builds, package installations,
and up-to-date targets in the `_targets` and `outputs`.
directory are all cached.  If some of your targets are file-based, you can add
them to the cached files by adding their paths in [GITHUB FILE]. More discussion
of cacheching options is are found in the `_targets.R` file. 

### Security and Environment Variables

This template uses [git-crypt] to store encrypted data. Environmental variables
such as API keys can be stored in the `.env` file.  This and any files under
`auth/` will be encrypted.  To encrypt additional files or directories, add them
to the `.gitattributes` file _before_ committing them. 

Variables in `.env` will be loaded into all R sessions, but if you end up including
shell commands in your workflows you will need to run `source .env` for your
shell scripts to have access to those variables.

Since this repository is an encrypted state, with `.env` accessible to only
to maintainers, one need to remove and reset the encryption so that you can set
your own variables in `.env` for things like GitHub actions. The `make nuke`
command in the Makefile clears out the encrypted files (including from git history).
You'll want to run `git push origin --force --all --tags` to then sync these history
changes to your git remote. You can then re-initialize your repository with
`git-crypt init` and add allowed users and sensitive data.

`git-crypt` uses GPG keys, so users can be given access to encrypted files
by adding their public GPG keys to the repository.  See the [manual][git-crypt]
for details.  All users needing to run code with encrypted variables and files 
will need to [set up GPG and `git-crypt`].

To enable GitHub actions to run code using encrypted info, run `make key` and
copy to output to a GitHub actions secret called `GIT_CRYPT_KEY64`, under
_Settings_ > _Secrets_ > _New Repository Secret_ 

[git-crypt]: https://www.agwa.name/projects/git-crypt/
[set up GPG and `git-crypt`]: https://ecohealthalliance.github.io/eha-ma-handbook/12-encryption.html

### Convenience templates and functions

The functions in `R/`, `_targets.R` workflow, and Example R Markdown targets 
found in `reports/` are all starting points to modify for your own projects.

Several functions are provided to help initial project setup and workflow. 

- `make rename to=NEWNAME` will rename any text or filenames from "repro-template"
to "NEWNAME". (Runs `rename_everywhere()`, found in `R/utils.R`)
- `make keybindings` sets up and prints default RStudio shortcuts for a bunch of 
useful actions for the project (Runs `set_keybindings(), found in `R/utils.R).
You can change these or add your own keyboard shortcuts in RStudio under 
`Tools > Modify Keyboard Shortcuts...`

</details>
