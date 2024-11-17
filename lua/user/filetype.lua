vim.filetype.add {
    pattern = {
        [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
        [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
        [".*/playbooks/.*%.yml"] = "yaml.ansible",
        [".*/playbooks/.*%.yaml"] = "yaml.ansible",
        [".*/roles/.*%.yml"] = "yaml.ansible",
        [".*/roles/.*%.yaml"] = "yaml.ansible",
        [".*/ansible/.*%.yml"] = "yaml.ansible",
        [".*/ansible/.*%.yaml"] = "yaml.ansible",
        [".*/roles/*/tasks/.*%.yml"] = "yaml.ansible",
        [".*/roles/*/tasks/.*%.yaml"] = "yaml.ansible",
        [".*%.ansible.yml"] = "yaml.ansible",
        [".*%.ansible.yaml"] = "yaml.ansible",
    },
}
