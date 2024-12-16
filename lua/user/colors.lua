local M = {}

M.diagnostics = {
    info = "#78a5a3",
    hint = "#82a0aa",
    warn = "#e1b16a",
    error = "#ce5a57",
}

M.diff = {
    added = "#78a5a3",
    modified = "#e1b16a",
    removed = "#ce5a57",
}

M.branch_type = {
    default = "#E2DFD0",
    int = "#8DA9C4",
    dev = "#AD49E1",
    nightly = "#AD49E1",
    feat = "#90EE90",
    fix = "#ce5a57",
    release = "#e1b16a",
}

M.general = {
    border = "#524C42",
    selection = "#7FB4CA",
    status_line_bg = "#181818",
}

M.custom = {
    white = "white",
    gray = "gray",
    gray2 = "#625e5a",
    gray3 = "#B7B7B7",
    light_red = "#ce5a57",
    light_green = "#90EE90",
    light_orange = "#e1b16a",
    light_cyan = "#82a0aa",
    light_purple = "#c792ea",
    light_gray = "#a0a1a7",
    sl_copilot = "#B7B7B7",
    sl_bg = "#181818",
    sl_filename = "#a0a1a7",
    sl_parent_path = "#545862",
    sl_lsp_progress = "#545862",
    sl_python_env = "#c4b28a",
}

return M
