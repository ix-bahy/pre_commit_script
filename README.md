# Add pre commit script

this is a simple bash script to add pre commit hooks to your exsiting python project or create a python project using them

## Requirments:

- git
- poetry "python dependancy mangment tool"
- pre-commit "pip install pre-commit"


## in an already existing project

download the script inside the project you want it to add the pre commit hooks to

```bash

./add_pre_commit.sh

```

## Create a new project

download the script

```bash

./add_pre_commit.sh --new --name <project_name>

```

this will create a new python poetry project in a new directory with the name you provided
