local M = {}

M.grammar_correction =
    "Correct the text to standard English, but keep any code blocks inside intact."
M.code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
]]
M.optimize_code = "Optimize the following code"
M.summarize = "Summarize the following text"
M.translate = "Translate this into Chinese, but keep any code blocks inside intact"
M.explain_code = "Explain the following code"
M.add_docstring = "Add docstring to the following codes"
M.fix_bugs = "Fix the bugs inside the following codes if any"
M.add_tests = "Implement tests for the following code"

return M
