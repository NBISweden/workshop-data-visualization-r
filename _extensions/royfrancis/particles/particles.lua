-- particles.lua --

-- Add html dependencies
local function addHTMLDeps()
  -- add the HTML requirements for the Bootstrap particles
  quarto.doc.add_html_dependency({
    name = 'particles',
    stylesheets = {'particles.css'}
  })
end

local utils = require 'pandoc.utils'
local has_json, json = pcall(require, 'pandoc.json')

local SCRIPT_URL = "https://cdn.jsdelivr.net/particles.js/2.0.0/particles.min.js"

local DEFAULT_CONFIG = {
  particles = {
    number = { value = 80, density = { enable = true, value_area = 800 } },
    color = { value = "#5b5b5b" },
    shape = {
      type = "circle",
      stroke = { width = 0, color = "#000000" },
      polygon = { nb_sides = 5 },
      image = { src = "img/github.svg", width = 100, height = 100 }
    },
    opacity = {
      value = 1,
      random = false,
      anim = { enable = false, speed = 1, opacity_min = 0.1, sync = false }
    },
    size = {
      value = 5,
      random = true,
      anim = { enable = false, speed = 40, size_min = 0.1, sync = false }
    },
    line_linked = {
      enable = true,
      distance = 150,
      color = "#5b5b5b",
      opacity = 0.4,
      width = 1
    },
    move = {
      enable = true,
      speed = 1,
      direction = "none",
      random = false,
      straight = false,
      out_mode = "out",
      bounce = false,
      attract = { enable = false, rotateX = 600, rotateY = 1200 }
    }
  },
  interactivity = {
    detect_on = "canvas",
    events = {
      onhover = { enable = true, mode = "repulse" },
      onclick = { enable = true, mode = "push" },
      resize = true
    },
    modes = {
      grab = { distance = 400, line_linked = { opacity = 1 } },
      bubble = { distance = 400, size = 40, duration = 2, opacity = 8, speed = 3 },
      repulse = { distance = 50, duration = 0.4 },
      push = { particles_nb = 4 },
      remove = { particles_nb = 2 }
    }
  },
  retina_detect = true
}

local instance_counter = 0

local function clone_table(source)
  local result = {}
  for key, value in pairs(source) do
    if type(value) == 'table' then
      result[key] = clone_table(value)
    else
      result[key] = value
    end
  end
  return result
end

local function is_array(tbl)
  local count = 0
  for key, _ in pairs(tbl) do
    if type(key) ~= 'number' then
      return false
    end
    count = count + 1
  end
  return count == #tbl
end

local function escape_json_string(str)
  local replacements = {
    ['"'] = '\\"',
    ['\\'] = '\\\\',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t'
  }
  return str:gsub('[\0-\31\\"]', function(char)
    return replacements[char] or string.format('\\u%04x', char:byte())
  end)
end

local function json_encode(value)
  local value_type = type(value)
  if value_type == 'table' then
    if is_array(value) then
      local items = {}
      for index = 1, #value do
        items[#items + 1] = json_encode(value[index])
      end
      return '[' .. table.concat(items, ',') .. ']'
    end
    local items = {}
    for key, val in pairs(value) do
      items[#items + 1] = '"' .. escape_json_string(tostring(key)) .. '":' .. json_encode(val)
    end
    return '{' .. table.concat(items, ',') .. '}'
  elseif value_type == 'string' then
    return '"' .. escape_json_string(value) .. '"'
  elseif value_type == 'number' then
    return tostring(value)
  elseif value_type == 'boolean' then
    return value and 'true' or 'false'
  else
    return 'null'
  end
end

local function merge_tables(base, override)
  for key, value in pairs(override) do
    if type(value) == 'table' and type(base[key]) == 'table' and not is_array(value) and not is_array(base[key]) then
      merge_tables(base[key], value)
    else
      base[key] = value
    end
  end
end

local function trim(text)
  return text:match('^%s*(.-)%s*$') or ''
end

local function parse_value(raw)
  if raw == nil then
    return nil
  end
  local raw_type = type(raw)
  if raw_type == 'boolean' or raw_type == 'number' then
    return raw
  end
  local string_value
  if raw_type == 'table' or raw_type == 'userdata' then
    local ok, text = pcall(utils.stringify, raw)
    string_value = ok and trim(text) or trim(tostring(raw))
  else
    string_value = trim(tostring(raw))
  end
  if string_value == '' then
    return ''
  end
  if string_value == 'true' then
    return true
  end
  if string_value == 'false' then
    return false
  end
  if string_value == 'null' or string_value == '~' then
    return nil
  end
  local numeric = tonumber(string_value)
  if numeric then
    return numeric
  end
  if has_json and (string_value:sub(1, 1) == '{' or string_value:sub(1, 1) == '[') then
    local ok, decoded = pcall(json.decode, string_value)
    if ok then
      return decoded
    end
  end
  return string_value
end

local function set_nested(target, keys, value)
  local key = table.remove(keys, 1)
  if key == nil then
    return
  end
  local numeric_key = tonumber(key)
  local final_key = numeric_key or key
  if #keys == 0 then
    target[final_key] = value
    return
  end
  local next_target = target[final_key]
  if type(next_target) ~= 'table' then
    next_target = {}
    target[final_key] = next_target
  end
  set_nested(next_target, keys, value)
end

local function split_key(key)
  local parts = {}
  for part in key:gmatch('[^%.]+') do
    parts[#parts + 1] = part
  end
  return parts
end

local function escape_attr(value)
  local replacements = { ['&'] = '&amp;', ['<'] = '&lt;', ['>'] = '&gt;', ['"'] = '&quot;', ["'"] = '&#39;' }
  return (value:gsub('[&<>"\']', replacements))
end

local function get_kwarg(kwargs, key)
  local value = kwargs[key]
  if value == nil then
    return nil
  end
  local value_type = type(value)
  if value_type == 'boolean' or value_type == 'number' then
    return tostring(value)
  end
  local text
  if value_type == 'string' then
    text = value
  else
    local ok, rendered = pcall(utils.stringify, value)
    text = ok and rendered or tostring(value)
  end
  local trimmed = trim(text)
  if trimmed == '' then
    return nil
  end
  return trimmed
end

local function particles(args, kwargs)
  kwargs = kwargs or {}
  instance_counter = instance_counter + 1

  local reserved_keys = {
    id = true,
    class = true,
    style = true,
    config = true,
    ['config-mode'] = true,
    config_mode = true
  }

  local id = get_kwarg(kwargs, 'id') or ('quarto-particles-js-' .. instance_counter)
  local class_attr = get_kwarg(kwargs, 'class')
  local extra_style_raw = kwargs['style']
  local extra_style
  if extra_style_raw ~= nil then
    if type(extra_style_raw) == 'string' then
      extra_style = trim(extra_style_raw)
    else
      local ok, rendered = pcall(utils.stringify, extra_style_raw)
      if ok then
        extra_style = trim(rendered)
      end
    end
    if extra_style == '' then
      extra_style = nil
    end
  end

  local config = clone_table(DEFAULT_CONFIG)

  local config_string = get_kwarg(kwargs, 'config')
  local config_mode = get_kwarg(kwargs, 'config-mode') or get_kwarg(kwargs, 'config_mode') or 'merge'
  if config_string and has_json then
    local ok, parsed = pcall(json.decode, config_string)
    if ok and type(parsed) == 'table' then
      if config_mode == 'replace' then
        config = parsed
      else
        merge_tables(config, parsed)
      end
    end
  end

  for key, raw_value in pairs(kwargs) do
    local key_string = tostring(key)
    if not reserved_keys[key_string] then
      local parsed_value = parse_value(raw_value)
      local path = split_key(key_string)
      if #path > 0 then
        set_nested(config, path, parsed_value)
      end
    end
  end

  if type(args) == 'table' then
    for _, entry in ipairs(args) do
      local text = utils.stringify(entry)
      local name, value = text:match('^([^=]+)%s*=%s*(.+)$')
      if name and value then
        name = trim(name)
        local parsed_value = parse_value(value)
        if not reserved_keys[name] then
          local path = split_key(name)
          if #path > 0 then
            set_nested(config, path, parsed_value)
          end
        end
      end
    end
  end

  local style = extra_style

  local class_value = 'quarto-particles-js'
  if class_attr and class_attr ~= '' then
    class_value = class_value .. ' ' .. class_attr
  end
  class_value = class_value .. ' ' .. id
  local class_attribute = ' class="' .. escape_attr(class_value) .. '"'

  local style_attribute = ''
  if style and style ~= '' then
    style_attribute = ' style="' .. escape_attr(style) .. '"'
  end

  local config_json = json_encode(config)

  local html = string.format([[<div id="%s"%s%s></div>
<script>
(function(){
  var targetId = %s;
  var config = %s;
  function initParticles() {
    if (typeof window.particlesJS === "function") {
      window.particlesJS(targetId, config);
    }
  }
  if (typeof window.particlesJS === "function") {
    initParticles();
    return;
  }
  window.__quartoParticles = window.__quartoParticles || { queue: [], loading: false };
  window.__quartoParticles.queue.push(initParticles);
  if (!window.__quartoParticles.loading) {
    window.__quartoParticles.loading = true;
    var script = document.createElement("script");
    script.src = "%s";
    script.async = true;
    script.onload = function() {
      window.__quartoParticles.queue.forEach(function(fn){ fn(); });
      window.__quartoParticles.queue = [];
      window.__quartoParticles.loading = false;
    };
    document.head.appendChild(script);
  }
})();
</script>]],
    escape_attr(id),
    class_attribute,
    style_attribute,
    json_encode(id),
    config_json,
    SCRIPT_URL
  )

  return pandoc.RawBlock('html', html)
end

return {
  ['particles'] = particles
}
