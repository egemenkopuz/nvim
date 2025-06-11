local M = {}

M.diagnostics = {
    info = "#78a5a3",
    hint = "#82a0aa",
    warn = "#ebbf7f",
    error = "#db7572",
}

M.diagnostics_dim = {
    info = "#78a5a3",
    hint = "#82a0aa",
    warn = "#c09863",
    error = "#99514f",
}

M.diff = {
    added = "#73bd73",
    modified = "#ebbf7f",
    removed = "#db7572",
}

M.diff_dim = {
    added = "#89a0aa",
    modified = "#ebbf7f",
    removed = "#6b3a3b",
}

M.branch_type = {
    default = "#E2DFD0",
    int = "#8DA9C4",
    dev = "#AD49E1",
    nightly = "#AD49E1",
    feat = "#90EE90",
    fix = "#db7572",
    release = "#ebbf7f",
}

M.general = {
    border = "#524C42",
    selection = "#7FB4CA",
    status_line_bg = "#181818",
}

M.patterns = {
    fix = "#db7572",
    hack = "#ebbf7f",
    warn = "#ffcc00",
    todo = "#80C4E9",
    perf = "#bb9af7",
    note = "#10b981",
}

M.custom = {
    std_bg = "#181818",
    white = "white",
    gray = "gray",
    gray2 = "#625e5a",
    gray3 = "#B7B7B7",
    light_red = "#db7572",
    light_green = "#90EE90",
    light_orange = "#ebbf7f",
    light_cyan = "#82a0aa",
    light_purple = "#c792ea",
    light_gray = "#a0a1a7",
    sl_copilot = "#B7B7B7",
    sl_bg = "#181818",
    sl_filename = "#a0a1a7",
    sl_parent_path = "#545862",
    sl_lsp_progress = "#545862",
    sl_conform = "#625458",
    sl_lint = "#586254",
    sl_python_env = "#c4b28a",
}

return M
