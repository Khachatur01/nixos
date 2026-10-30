-- Hardware discovery for conky. Every conky_* function is called from conky.text
-- and returns either a value or conky markup (via lua_parse).

local H = "${font monospace:bold:size=11}"
local function head(color, title, extra)
  return "${color3}" .. H .. title .. "${font}" .. (extra or "") .. "${color}${hr 2}\n"
end

local function readfile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function exists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

-- CPU: one bar per logical CPU, two per row -----------------------------------
function conky_cpu_rows()
  local n = 0
  for _ in (readfile("/proc/cpuinfo") or ""):gmatch("\nprocessor%s*:") do n = n + 1 end
  if (readfile("/proc/cpuinfo") or ""):match("^processor%s*:") then n = n + 1 end
  if n == 0 then n = 1 end

  local function cell(i, x)
    return string.format(
      "${goto %d}${color2}%d${goto %d}${color1}${cpu cpu%d}%%${goto %d}${cpubar cpu%d 6,60}",
      x, i, x + 35, i, x + 75, i)
  end

  local out = {}
  for i = 1, n, 2 do
    local row = cell(i, 0)
    if i + 1 <= n then row = row .. cell(i + 1, 170) end
    out[#out + 1] = row
  end
  return table.concat(out, "\n")
end

-- NVIDIA via nvidia-smi (cached per second) -----------------------------------
local nvsmi
for _, p in ipairs({
  "/run/current-system/sw/bin/nvidia-smi",
  "/run/opengl-driver/bin/nvidia-smi",
  "/usr/bin/nvidia-smi",
  "/usr/local/bin/nvidia-smi",
}) do
  if exists(p) then nvsmi = p break end
end

local nv_cache, nv_time = {}, 0
local function nv_gpus()
  if not nvsmi then return {} end
  local now = os.time()
  if now == nv_time then return nv_cache end
  nv_time = now
  nv_cache = {}
  local p = io.popen(nvsmi ..
    " --query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw" ..
    " --format=csv,noheader,nounits 2>/dev/null")
  if p then
    for line in p:lines() do
      local f = {}
      for v in line:gmatch("[^,]+") do f[#f + 1] = v:match("^%s*(.-)%s*$") end
      if #f >= 7 then
        nv_cache[#nv_cache + 1] = {
          name = f[2]:gsub("^NVIDIA ", ""):gsub("^GeForce ", ""),
          util = tonumber(f[3]) or 0,
          used = tonumber(f[4]) or 0, total = tonumber(f[5]) or 1,
          temp = f[6], power = f[7],
        }
      end
    end
    p:close()
  end
  return nv_cache
end

function conky_nv_util(i) return (nv_gpus()[tonumber(i)] or {}).util or 0 end
function conky_nv_vram_pct(i)
  local g = nv_gpus()[tonumber(i)]
  return g and math.floor(g.used * 100 / g.total) or 0
end

-- AMD via amdgpu sysfs --------------------------------------------------------
local function amd_gpus()
  local list = {}
  for c = 0, 15 do
    local d = "/sys/class/drm/card" .. c .. "/device/"
    if exists(d .. "gpu_busy_percent") and exists(d .. "mem_info_vram_total") then
      local vendor = (readfile(d .. "vendor") or ""):gsub("%s+", "")
      if vendor == "0x1002" then list[#list + 1] = d end
    end
  end
  return list
end

local function sysfs_num(path)
  return tonumber((readfile(path) or ""):match("%d+")) or 0
end

function conky_amd_util(i)
  local d = amd_gpus()[tonumber(i)]
  return d and sysfs_num(d .. "gpu_busy_percent") or 0
end
function conky_amd_vram_pct(i)
  local d = amd_gpus()[tonumber(i)]
  if not d then return 0 end
  local total = sysfs_num(d .. "mem_info_vram_total")
  return total > 0 and math.floor(sysfs_num(d .. "mem_info_vram_used") * 100 / total) or 0
end
function conky_amd_vram(i)
  local d = amd_gpus()[tonumber(i)]
  if not d then return "" end
  return string.format("%d / %d MiB",
    math.floor(sysfs_num(d .. "mem_info_vram_used") / 1048576),
    math.floor(sysfs_num(d .. "mem_info_vram_total") / 1048576))
end

function conky_gpu_section()
  local out = {}
  for i, g in ipairs(nv_gpus()) do
    out[#out + 1] = head("", "GPU", "  ${color1}" .. g.name)
    out[#out + 1] = string.format(
      "${color2}Load${goto 80}${color1}${lua nv_util %d}%%${goto 130}${lua_bar 6,150 nv_util %d}\n" ..
      "${color2}VRAM${goto 80}${color1}%d / %d MiB${goto 220}${alignr}${lua nv_vram_pct %d}%%\n" ..
      "${goto 80}${lua_bar 6 nv_vram_pct %d}\n" ..
      "${color2}Temp${goto 80}${color1}%s°C${goto 170}${color2}Power${goto 215}${color1}%s W\n",
      i, i, g.used, g.total, i, i, g.temp, g.power)
  end
  for i, d in ipairs(amd_gpus()) do
    out[#out + 1] = head("", "GPU", "  ${color1}AMD " .. (d:match("card(%d+)") or i))
    out[#out + 1] = string.format(
      "${color2}Load${goto 80}${color1}${lua amd_util %d}%%${goto 130}${lua_bar 6,150 amd_util %d}\n" ..
      "${color2}VRAM${goto 80}${color1}${lua amd_vram %d}${alignr}${lua amd_vram_pct %d}%%\n" ..
      "${goto 80}${lua_bar 6 amd_vram_pct %d}\n",
      i, i, i, i, i)
  end
  return table.concat(out, "\n")
end

-- Disks: every real, distinct mounted block device ---------------------------
local real_fs = {
  ext2 = 1, ext3 = 1, ext4 = 1, btrfs = 1, xfs = 1, f2fs = 1, zfs = 1,
  ntfs = 1, ntfs3 = 1, ["fuseblk"] = 1, vfat = 1, exfat = 1,
}
local skip_prefix = { "/nix/store", "/boot", "/efi", "/var/lib", "/run", "/sys", "/proc", "/dev" }

function conky_disk_section()
  local seen, out = {}, {}
  for line in (readfile("/proc/mounts") or ""):gmatch("[^\n]+") do
    local dev, mp, fs = line:match("^(%S+) (%S+) (%S+)")
    if dev and real_fs[fs] and dev:sub(1, 1) == "/" and not seen[dev] then
      local skip = false
      for _, p in ipairs(skip_prefix) do
        if mp == p or mp:sub(1, #p + 1) == p .. "/" then skip = true break end
      end
      if not skip then
        seen[dev] = true
        mp = mp:gsub("\\040", " ")
        out[#out + 1] = string.format(
          "${color2}%s${goto 80}${color1}${fs_used %s} / ${fs_size %s}${alignr}${fs_used_perc %s}%%\n" ..
          "${color4}${fs_bar 6 %s}",
          mp, mp, mp, mp, mp)
      end
    end
  end
  return table.concat(out, "\n")
end
