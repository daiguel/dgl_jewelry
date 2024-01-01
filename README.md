# OP
 - [[ESX/QB] Jewelry Robbery](https://forum.cfx.re/t/esx-qb-jewelry-robbery/5180602)
# Jewelry Heist
**Note:** This isn't the original release; this version has been modified.

## Dependencies
Ensure the following resources are included in your project:

- [ox_target](https://github.com/overextended/ox_target.git)
- [ox_lib](https://github.com/overextended/ox_lib.git)
- [mka-lasers](https://github.com/daiguel/mka-lasers.git) - Download the forked version.

## Installation Steps
0. start those depencies first

1. 
```bash
git clone https://github.com/daiguel/dgl_jewelry.git
```
`ensure dgl_jewelry` in server.cfg

2. Read and configure `config.lua`.

3. Open `config/functions.lua`:
Choose your preferred notification and dispatch functions.

4. Restart your server to apply changes.

## Updates
- Threads replaced with targets.
- Unnecessary threads, variables, events, and functions was removed for optimization.
- Refactored certain functions for better performance.
- Added MKA lasers, spray functionality, and necessary items required for each step.

## Performance Metrics
- **Idle:** 0.00 ms
- **High Usage:** Occurs when lasers are activated after doors unlock and remain activated until deactivated (via hack or cooldown end). Approximately 0.06 ms, dependent on the number of active lasers.

## Items (ox_inventory format)

```lua
    ["ring"] = {
        label = "ring",
        weight = 10,
        stack = true,
        close = true,
    },
    ["bracelet"] = {
        label = "bracelet",
        weight = 30,
        stack = true,
        close = true,
    },
    ["chain"] = {
        label = "chain",
        weight = 30,
        stack = true,
        close = true,
    },
    ["clock"] = {
        label = "clock",
        weight = 70,
        stack = true,
        close = true,
    },
    ["painting"] = {
        label = "painting",
        weight = 5,
        stack = true,
        close = true,
    },
    ["earrings"] = {
        label = "earrings",
        weight = 10,
        stack = true,
        close = true,
    },
    ["spray"] = {
        label = "spray",
        weight = 500,
        stack = true,
        client = {
            event="dgl_jewelry:startSpray"
        },
        close = true,
    },
    ["drill"] = {
        label = "drill",
        weight = 2000,
        stack = false,
        close = true,
    },
    ["computer"] = {
        label = "computer",
        weight = 2000,
        stack = false,
        close = true,
    },
    ["alphawifi"] = {
        label = "alphawifi",
        weight = 2000,
        stack = false,
        close = true,
    },
```