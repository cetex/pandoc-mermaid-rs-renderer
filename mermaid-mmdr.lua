-- mermaid-mmdr.lua
-- Pandoc Lua filter for rendering mermaid diagrams using mmdr (Rust-based renderer).
-- No Chromium or Node.js required.
--
-- Usage:
--   pandoc --lua-filter mermaid-mmdr.lua input.md -o output.pdf
--
-- Mermaid code blocks (```mermaid ... ```) are rendered to SVG via mmdr
-- and included as images in the output document.
--
-- Optional code block attributes:
--   caption="Figure caption"   - adds a figure caption
--   alt="Description"          - sets alt text (default: "Mermaid diagram")
--   format="png"               - override output format for this diagram ("svg" or "png")
--
-- Environment variables:
--   MERMAID_CACHE_DIR  - directory for cached renders (default: /tmp/mermaid-cache)
--   MERMAID_FORMAT     - output format: "svg" (default) or "png"
--   MMDR_CONFIG        - path to mmdr config.json (optional)

local diagram_count = 0

local cache_dir = os.getenv("MERMAID_CACHE_DIR") or "/tmp/mermaid-cache"
local default_format = os.getenv("MERMAID_FORMAT") or "svg"
local mmdr_config = os.getenv("MMDR_CONFIG") or ""

os.execute("mkdir -p " .. cache_dir)

-- Simple djb2 hash for cache filenames
local function hash(str)
  local h = 5381
  for i = 1, #str do
    h = ((h * 33) + string.byte(str, i)) % 2147483647
  end
  return string.format("%x", h)
end

function CodeBlock(block)
  if not block.classes[1] or block.classes[1] ~= "mermaid" then
    return nil
  end

  diagram_count = diagram_count + 1

  local code = block.text
  local format = block.attributes.format or default_format
  local code_hash = hash(code)
  local img_file = cache_dir .. "/mermaid-" .. code_hash .. "." .. format

  -- Check cache first
  local cached = io.open(img_file, "r")
  if cached then
    cached:close()
  else
    -- Write mermaid source to temp file
    local tmp_input = os.tmpname() .. ".mmd"
    local f = io.open(tmp_input, "w")
    if not f then
      io.stderr:write("ERROR: Could not create temp file for mermaid diagram\n")
      return nil
    end
    f:write(code)
    f:close()

    -- Build mmdr command
    local config_flag = ""
    if mmdr_config ~= "" then
      config_flag = " -c " .. mmdr_config
    end
    local cmd = string.format("mmdr -i %s -o %s -e %s%s 2>&1", tmp_input, img_file, format, config_flag)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    local success = handle:close()

    os.remove(tmp_input)

    if not success then
      io.stderr:write("WARNING: mmdr failed to render diagram " .. diagram_count .. "\n")
      io.stderr:write(result .. "\n")
      return pandoc.CodeBlock("MERMAID RENDER ERROR:\n" .. result .. "\n\nOriginal:\n" .. code)
    end
  end

  local caption = block.attributes.caption or ""
  local alt_text = block.attributes.alt or "Mermaid diagram"

  local img = pandoc.Image({pandoc.Str(alt_text)}, img_file)

  if caption ~= "" then
    return pandoc.Figure(
      pandoc.Plain({img}),
      {pandoc.Str(caption)},
      pandoc.Attr(block.identifier or "", block.classes, block.attributes)
    )
  else
    return pandoc.Para({img})
  end
end
