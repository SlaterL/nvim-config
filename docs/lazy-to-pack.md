# Migrating from `lazy.nvim` to `vim.pack`

Neovim **0.12** introduces **`vim.pack`**, a native module for declaratively
downloading and managing plugins. While `lazy.nvim` is a full framework that
handles lazy-loading, UI management, and modular keymaps, `vim.pack` focuses on
simplicity, leveraging core Neovim mechanisms without third-party dependencies.

> **Version requirement:** `vim.pack` landed in **Neovim 0.12** (it is *not* in
> 0.11, despite what some early write-ups claim). Check with
> `:lua print(vim.fn.has('nvim-0.12'))` — it must return `1`. On 0.11,
> `vim.pack` is `nil` and any `vim.pack.add` call errors with
> `attempt to index field 'pack' (a nil value)`.

---

## 1. Philosophical Differences

| Feature | `lazy.nvim` | `vim.pack` (Neovim 0.12+) |
| --- | --- | --- |
| **Setup** | Bootstrapped via Lua script in `init.lua` | Built into Neovim core (zero setup) |
| **Lazy Loading** | Built-in via `keys`, `ft`, `cmd`, `event` | Handled manually via `Autocmds`, `after/`, or `ftplugin/` |
| **Plugin Specs** | Bundles `config`, `opts`, `keys`, `dependencies` in one table | Accepts source URLs or specs; setup code is placed outside |
| **UI** | Interactive floating UI window (`:Lazy`) | Native text-buffer diff UI for updates |
| **Lockfile** | `lazy-lock.json` | `nvim-pack-lock.json` (in `stdpath("config")`) |
| **Management** | `:Lazy` commands | Lua API: `vim.pack.update/del/get` |

---

## 2. Step-by-Step Migration Guide

### Step 1: Clean Up Old `lazy.nvim` Artifacts

1. Delete or comment out the `lazy.nvim` bootstrapping code at the top of your configuration:
```lua
-- REMOVE OR COMMENT OUT THIS BLOCK:
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then ... end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup(...)
```

2. Remove your old lockfile (`lazy-lock.json`) **only once you are fully off
   lazy**. During an incremental migration (Section 4) keep it.

---

### Step 2: Convert Plugin Declarations

With `vim.pack`, pass a flat list of plugin sources to `vim.pack.add()`.

#### **Before (`lazy.nvim`)**

```lua
require("lazy").setup({
  "nvim-lua/plenary.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "stevearc/oil.nvim", opts = {} },
})
```

#### **After (`vim.pack`)**

```lua
vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    version = 'v0.1.8', -- see Step 4 for version/branch semantics
  },
  'https://github.com/stevearc/oil.nvim',
})

-- Configure plugins inline after adding them
require('oil').setup({})
```

> **Dependencies are not automatic.** Unlike lazy's `dependencies`, `vim.pack`
> does not resolve a dependency graph. List every dependency explicitly, and put
> dependencies **before** the plugins that need them so they are on `rtp` first
> (e.g. `plenary.nvim` before `telescope.nvim`). See also the shared-dependency
> gotcha in Section 4.

---

### Step 3: Handle Plugin Setup and Configuration

`lazy.nvim` executes `config = function() ... end` or passes `opts` directly to
`.setup()`. In `vim.pack`, simply invoke `.setup()` directly **after** calling
`vim.pack.add()`.

```lua
vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })

require('nvim-treesitter.configs').setup({
  highlight = { enable = true },
})
```

---

### Step 4: Version and Branch Pinning

`vim.pack`'s `version` field accepts **either**:

- a **plain string ref** — a branch, tag, or commit (used verbatim), or
- a **`vim.version.range(...)`** — a semver constraint that picks a matching tag.

```lua
vim.pack.add({
  -- Track a branch (was lazy `branch = "0.1.x"`):
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = '0.1.x' },

  -- Pin a specific tag:
  { src = 'https://github.com/user/plugin', version = 'v1.2.3' },

  -- Semver range (was lazy `version = "^1.0.0"`, i.e. >=1.0.0 <2.0.0):
  { src = 'https://github.com/user/plugin', version = vim.version.range('1') },
})
```

> **⚠️ Watch out for changed default branches.** `vim.pack` installs a repo's
> **default branch** unless you pin `version`. Some plugins have moved their
> default to an incompatible rewrite — the prime example is
> **`nvim-treesitter`**, whose default is now `main` (a rewrite that lacks
> `require("nvim-treesitter.configs").setup(...)`). If your config uses the
> classic API, pin `version = "master"`.
>
> Note: on a fresh install, `git rev-parse --abbrev-ref HEAD` may momentarily
> report the default branch mid-checkout. Verify against `origin/<branch>`
> (`git rev-parse HEAD` vs `git rev-parse origin/master`) if scripting checks.

---

### Step 5: Handle Lazy Loading / Event-based Actions

`vim.pack` loads plugins directly onto your runtime path without explicit
lazy-loading options (`cmd`, `event`, `keys`). Replicate deferred behavior with
native autocommands, `ftplugin/`, or `after/`. In practice, most lightweight
plugins can just be set up eagerly.

#### Build steps: use the native `PackChanged` event

`lazy`'s `build = ":TSUpdate"` / `build = "make"` becomes the built-in
**`PackChanged`** event.

> **⚠️ `PackChanged` is a native event, not a `User` pattern.** Register it as
> `nvim_create_autocmd('PackChanged', ...)` — *not*
> `nvim_create_autocmd('User', { pattern = 'PackChanged' })`.
>
> The event data (`ev.data`) has: `kind` (`"install" | "update" | "delete"`),
> `spec` (the resolved spec — use `ev.data.spec.name`), `path` (plugin dir),
> and `active`. There is **no** `ev.data.name`.

Register the autocmd **before** the corresponding `vim.pack.add()` so it fires
for a fresh install (install fires *before* the plugin is loaded).

**Vim-command build (e.g. `:TSUpdate`):**
```lua
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind ~= 'delete' then
      vim.schedule(function()
        if vim.fn.exists(':TSUpdate') == 2 then vim.cmd('TSUpdate') end
      end)
    end
  end,
})
```

**Shell build (e.g. `make`) — must be NON-BLOCKING:**
```lua
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'telescope-fzf-native.nvim' and ev.data.kind ~= 'delete' then
      local path = ev.data.path
      vim.schedule(function()
        vim.system({ 'make' }, { cwd = path }, function(out)
          if out.code == 0 then
            vim.schedule(function() pcall(require('telescope').load_extension, 'fzf') end)
          end
        end)
      end)
    end
  end,
})
```

> **⚠️ Do not block inside a `PackChanged` callback.** It runs *inside*
> `vim.pack`'s async install/update loop, so `vim.system({...}):wait()` (or any
> `vim.wait`) errors with a "cannot wait inside async context" traceback.
> Always `vim.schedule` the work and use the async callback form of
> `vim.system`. On a fresh install the extension/build finishes slightly after
> `vim.pack.add` returns, so wrap the immediate `load_extension` in `pcall` and
> also load it from the async callback on success.

#### Conditional install (`cond`)

`lazy`'s `cond = function() ... end` has no direct equivalent — just build the
spec list conditionally:
```lua
local specs = { 'https://github.com/nvim-telescope/telescope.nvim' }
if vim.fn.executable('make') == 1 then
  table.insert(specs, 'https://github.com/nvim-telescope/telescope-fzf-native.nvim')
end
vim.pack.add(specs)
```

---

## 3. Managing Plugins Post-Migration

Management is done through the **Lua API** (there are no `:packupdate` /
`:packdel` ex-commands — the only classic command is `:packadd`, which
`vim.pack` uses internally):

- **`vim.pack.update()`** — fetch updates for all plugins and open an
  interactive diff buffer. Save the buffer (`:w`) to apply, `:q` to cancel.
  `vim.pack.update({ 'name' })` updates a subset.
- **`vim.pack.del({ 'name' })`** — remove a plugin from disk. (Also remove its
  spec from `vim.pack.add`, or it will be reinstalled.)
- **`vim.pack.get()`** — list installed plugins / inspect state.
- **`nvim-pack-lock.json`** — generated in `stdpath("config")` (i.e.
  `~/.config/nvim/nvim-pack-lock.json`). Commit it to keep versions locked
  across machines. A log file `nvim-pack.log` lives at the `log` standard-path.

---

## 4. Incremental Migration Alongside `lazy.nvim`

You can migrate one plugin at a time while lazy still manages the rest. This
config uses the pattern below. **There are two hard conflicts between lazy and
`vim.pack` that must be handled — both stem from lazy rewriting the runtime
paths during `lazy.setup()`.**

### The pattern used here

- Migrated (vim.pack) plugins live in **`lua/pack/`**, one file per plugin.
  Lazy's `{ import = "plugins" }` never touches that directory, so there is **no
  per-file boilerplate** — each file just calls `vim.pack.add` + `setup` +
  keymaps.
- A single central loader in `init.lua`, placed **after** `lazy.setup(...)`,
  requires every file in `lua/pack/`.

```lua
require("lazy").setup({ { import = "plugins" } })

-- [[ vim.pack-managed plugins ]]
-- (1) lazy strips 'packpath' during setup; restore the site dir so vim.pack's
--     install location is searchable by :packadd.
vim.opt.packpath:prepend(vim.fn.stdpath("data") .. "/site")
-- (2) Defer to after startup so :packadd sources each plugin's plugin/ files.
vim.schedule(function()
  for _, file in ipairs(vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/pack", "*.lua", false, true)) do
    require("pack." .. vim.fn.fnamemodify(file, ":t:r"))
  end
end)
```

Migrating a plugin then means: add `lua/pack/<name>.lua`, delete the old
`lua/plugins/<name>.lua`. To fully finish the migration later, drop lazy, remove
the `packpath:prepend` line, and `vim.schedule` becomes optional.

### Gotcha 1 — lazy strips `packpath`

`lazy.setup()` resets `packpath` down to just `$VIMRUNTIME`, removing the
default site dir (`stdpath("data") .. "/site"`) where `vim.pack` installs
plugins. Any `vim.pack.add` that runs afterward fails to *load* with:

```
E919: Directory not found in 'packpath': "pack/*/opt/<plugin>"
```

Fix: `vim.opt.packpath:prepend(vim.fn.stdpath("data") .. "/site")` once, before
loading pack plugins (as above).

> Alternative: `lazy.setup({ ..., performance = { rtp = { reset = false } } })`
> stops lazy from stripping the paths in the first place.

### Gotcha 2 — `plugin/` files aren't sourced during startup

When `vim.pack.add` runs **during** startup, the internal `:packadd` adds the
plugin to `rtp` but does **not** source its `plugin/*.lua` files (so user
commands like `:Grapple`, `:Telescope` never get created). It appears to "work"
if the call happens to run inside `lazy.setup`'s own load pass, but not from a
plain loader after it.

Fix: run the pack loader **after startup** via `vim.schedule` (as above). Then
`:packadd` sources `plugin/` files immediately and commands are created.

### Gotcha 3 — shared dependencies

If a dependency (e.g. `plenary.nvim`) is used by *both* a migrated plugin and
plugins still managed by lazy, you must add it via `vim.pack` for the migrated
plugin. Lazy only puts such deps on `rtp` when it loads one of *its* plugins
that needs them, so it won't be available to your vim.pack plugin at setup time.
Having two copies (lazy's + vim.pack's) during the transition is harmless.

---

## 5. (Optional) Recreating a Modular Helper

If you prefer lazy's per-plugin `config` syntax, wrap `vim.pack.add`:

```lua
local function setup_plugins(specs)
  local pack_specs, configs = {}, {}
  for _, spec in ipairs(specs) do
    if type(spec) == "string" then
      table.insert(pack_specs, spec)
    else
      table.insert(pack_specs, { src = spec.src, name = spec.name, version = spec.version })
      if spec.config then table.insert(configs, spec.config) end
    end
  end
  vim.pack.add(pack_specs)
  for _, config in ipairs(configs) do config() end
end

setup_plugins({
  {
    src = "https://github.com/stevearc/oil.nvim",
    config = function() require("oil").setup({}) end,
  },
})
```
