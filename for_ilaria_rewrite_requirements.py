file_base = "requirements_conda_base.txt"
file_project = "sherpa_requirements.txt"

with open(file_base, "r") as f:
    base_reqs = f.readlines()

with open(file_project, "r") as f:
    project_reqs = f.readlines()

new_reqs = [line for line in project_reqs if line not in base_reqs]
print("".join(new_reqs))

