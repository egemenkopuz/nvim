local M = {}

M.dashboard = [[
 ███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗
 ████╗  ██║ ██║   ██║ ██║ ████╗ ████║
 ██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║
 ██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
 ██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║
 ╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝
          deus est machina           
]]

M.borders = {
    none = { "", "", "", "", "", "", "", "" },
    invs = { " ", " ", " ", " ", " ", " ", " ", " " },
    thin = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    sharp = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
}

M.diagnostics = {
    error = " ",
    warn = " ",
    info = " ",
    hint = " ",
}

M.diff = {
    added = "+",
    modified = "~",
    removed = "-",
}

M.custom = {
    branch = "",
    copilot = "",
    macro_recording = " ",
    user = "",
    lock = "",
}

-- Syntax icons
M.kinds = {
    Text = " ",
    Method = "󰆧 ",
    Function = "󰊕 ",
    Constructor = " ",
    Field = "󰇽 ",
    Variable = "󰂡 ",
    Class = "󰠱 ",
    Interface = " ",
    Module = " ",
    Property = "󰜢 ",
    Unit = " ",
    Value = "󰎠 ",
    Enum = " ",
    Keyword = "󰌋 ",
    Snippet = " ",
    Color = "󰏘 ",
    File = "󰈙 ",
    Reference = " ",
    Folder = "󰉋 ",
    EnumMember = " ",
    Constant = "󰏿 ",
    Struct = "󱡠 ",
    Event = " ",
    Operator = "󰆕 ",
    TypeParameter = "󰅲 ",
    Namespace = " ",
    Table = " ",
    Object = "󰙞 ",
    Tag = " ",
    Array = "[] ",
    Boolean = " ",
    Number = " ",
    Null = "󰟢 ",
    String = " ",
    Calendar = " ",
    Watch = "󰖉 ",
    Package = " ",
    Copilot = " ",
}

M.clangd = {
    role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
    },
    kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
    },
}

return M
