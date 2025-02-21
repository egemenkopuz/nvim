return {
    {
        "Eandrju/cellular-automaton.nvim",
        init = function()
            require("user.utils").load_keymap "cellular_automaton"
        end,
        lazy = false,
    },
}
