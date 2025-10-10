# CLAUDE.md

> NixOS Configuration - Modern CLI Toolkit Optimization

## Tech Stack
- **OS**: NixOS 25.11 with Nix Flakes
- **Desktop**: GNOME (Wayland)
- **Shell**: Fish with Starship prompt
- **Terminal**: Kitty with JetBrains Mono Nerd Font
- **Package Manager**: Nix + Home Manager
- **Development**: DevEnv + Direnv for project environments

## Essential Commands

### System Management
- `./rebuild-nixos` - Interactive rebuild with safety checks (PREFERRED)
- `sudo nixos-rebuild switch --flake .` - Direct system rebuild
- `nix flake check` - Validate configuration syntax
- `nix develop` or `devenv shell` - Enter development environment

### AI Orchestration
- `./ai-orchestration/scripts/master-orchestrator.sh` - Master control system
- `claude-flow` or `npx claude-flow@alpha` - Enterprise AI coordination
- `ai filename.py` - Quick AI pair programming session
- `aicode src/*.py` - Pre-configured Claude Sonnet session

### Modern CLI Tools (ALWAYS USE THESE)
- `fd` instead of `find` - Fast file searching
- `eza` instead of `ls` - Enhanced directory listing
- `bat` instead of `cat` - Syntax-highlighted file viewing
- `rg` instead of `grep` - Ultra-fast text search
- `dua` instead of `du` - Interactive disk usage
- `procs` instead of `ps` - Modern process viewer
- `jless` instead of `less` for JSON files
- `yq` for YAML processing
- `glow` for markdown rendering

## Project Structure
- `flake.nix` - Main configuration entry point
- `modules/core/packages.nix` - System-wide packages (116 tools)
- `modules/home-manager/base.nix` - User configs and Fish shell setup
- `hosts/nixos/` - Hardware-specific configuration
- `basb-system/` - Building a Second Brain knowledge management
- `ai-orchestration/` - Multi-agent AI coordination system
- `stack-management/` - Technology stack lifecycle management

## Development Conventions

### Adding Packages
- **System tools**: Add to `modules/core/packages.nix`
- **User programs**: Add to `modules/home-manager/base.nix`
- **Project-specific**: Use `devenv.nix` or `shell.nix`

### Configuration Changes
- Always run `nix flake check` before rebuilding
- Use `./rebuild-nixos` for interactive safety checks
- Test with `nixos-rebuild test --flake .` first
- Keep modules focused on single responsibilities

### Code Style
- Follow existing Nix formatting conventions
- Use descriptive comments for complex configurations
- Group related packages logically
- Include URLs for package references when helpful

## Working Features ✅
- Fish shell with smart abbreviations
- Yazi file manager with rich previews
- Starship prompt with visual git status
- Auto-updating Claude Code tool intelligence
- BASB knowledge management system
- AI orchestration with CCPM integration
- Chrome declarative extension management

## Do Not Touch
- `/etc/nixos/` (use this repo instead)
- `result` symlinks (Nix build artifacts)
- Files in `hosts/nixos/hardware-configuration.nix` (auto-generated)

## Special Notes
- System uses automated Claude Code optimization (updates tool knowledge automatically)
- Fish shell context-aware commands (different behavior for interactive vs automated)
- Chrome extensions managed declaratively via NixOS
- BASB system integrated with Google Workspace + Sunsama + Readwise

## Architecture Philosophy
- **System-level tools**: Universal access for AI agents (116 tools in `packages.nix`)
- **Project-level tools**: Context-specific via devenv/package.json
- **Modular design**: Inspired by ZaneyOS architecture
- **AI-first optimization**: Tools selected for Claude Code compatibility

## Performance Optimization
- Build limited to 4 CPU cores, 2 parallel jobs
- Zram swap (25% RAM) with zstd compression
- Weekly garbage collection + monthly updates automated
- Interactive cache cleanup (UV, Chrome, Yarn, Playwright)

## System Status
- **Git Status**: 2M 0A 0U
- **Last Updated**: 2025-10-09 03:04:17
- **Fish Abbreviations**: 56
- **Total System Tools**: 116

---
*Auto-updated by ./rebuild-nixos script*

## 🔌 MCP Server Status

**Last Updated**: 2025-10-10 15:58:47
**Analysis Period**: 30 days

### Configured Servers (2)

**1. sequential-thinking** ✓ CONNECTED
   - **Type**: npm
   - **Command**: `npx @modelcontextprotocol/server-sequential-thinking`
   - **Location**: global (~/.claude.json)
   - **Description**: Step-by-step reasoning for complex problems
**2. serena** ✓ CONNECTED
   - **Type**: binary
   - **Command**: `serena start-mcp-server --context ide-assistant`
   - **Location**: global (~/.claude.json)
   - **Description**: Semantic code analysis toolkit

### Connection Health

- ✅ **Connected**: 2 server(s)
  - sequential-thinking
  - serena


### Usage Analytics

**Total MCP invocations**: 488
**Total tokens consumed**: 4,875,429
**Estimated total cost**: $30.6206

#### sequential-thinking.sequentialthinking (global scope)

**Usage Metrics:**
- Invocations: 305
- Success rate: 0.0%
- Last used: 2025-10-10 13:36

**Token Consumption:**
- Total tokens: 2,489,545 (Input: 115,720, Output: 109,167)
- Cache tokens: 24,464,197 reads, 2,264,658 writes
- Avg tokens/invocation: 8162

**Cost Analysis:**
- Estimated cost: $17.8164
- ROI score: 0.12 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.navigate_page (unknown scope)

**Usage Metrics:**
- Invocations: 17
- Success rate: 0.0%
- Last used: 2025-10-08 18:36

**Token Consumption:**
- Total tokens: 359,142 (Input: 205, Output: 2,860)
- Cache tokens: 1,477,850 reads, 356,077 writes
- Avg tokens/invocation: 21126

**Cost Analysis:**
- Estimated cost: $1.8222
- ROI score: 0.05 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### whatsapp.list_chats (unknown scope)

**Usage Metrics:**
- Invocations: 19
- Success rate: 0.0%
- Last used: 2025-10-09 17:59

**Token Consumption:**
- Total tokens: 330,806 (Input: 162, Output: 2,438)
- Cache tokens: 988,508 reads, 328,206 writes
- Avg tokens/invocation: 17411

**Cost Analysis:**
- Estimated cost: $1.5644
- ROI score: 0.06 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.list_dir (global scope)

**Usage Metrics:**
- Invocations: 24
- Success rate: 0.0%
- Last used: 2025-10-10 12:23

**Token Consumption:**
- Total tokens: 241,241 (Input: 746, Output: 1,805)
- Cache tokens: 966,528 reads, 238,690 writes
- Avg tokens/invocation: 10052

**Cost Analysis:**
- Estimated cost: $1.2144
- ROI score: 0.10 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.think_about_collected_information (global scope)

**Usage Metrics:**
- Invocations: 8
- Success rate: 0.0%
- Last used: 2025-10-08 23:48

**Token Consumption:**
- Total tokens: 194,034 (Input: 5,491, Output: 4,575)
- Cache tokens: 548,435 reads, 183,968 writes
- Avg tokens/invocation: 24254

**Cost Analysis:**
- Estimated cost: $0.9395
- ROI score: 0.04 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.click (unknown scope)

**Usage Metrics:**
- Invocations: 15
- Success rate: 0.0%
- Last used: 2025-10-08 18:36

**Token Consumption:**
- Total tokens: 157,289 (Input: 181, Output: 2,481)
- Cache tokens: 1,207,329 reads, 154,627 writes
- Avg tokens/invocation: 10486

**Cost Analysis:**
- Estimated cost: $0.9798
- ROI score: 0.10 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### whatsapp.list_messages (unknown scope)

**Usage Metrics:**
- Invocations: 14
- Success rate: 0.0%
- Last used: 2025-10-09 18:00

**Token Consumption:**
- Total tokens: 155,682 (Input: 138, Output: 1,889)
- Cache tokens: 731,589 reads, 153,655 writes
- Avg tokens/invocation: 11120

**Cost Analysis:**
- Estimated cost: $0.8244
- ROI score: 0.09 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.search_for_pattern (global scope)

**Usage Metrics:**
- Invocations: 11
- Success rate: 0.0%
- Last used: 2025-10-10 08:52

**Token Consumption:**
- Total tokens: 144,511 (Input: 1,546, Output: 1,666)
- Cache tokens: 444,884 reads, 141,299 writes
- Avg tokens/invocation: 13137

**Cost Analysis:**
- Estimated cost: $0.6930
- ROI score: 0.08 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.find_symbol (global scope)

**Usage Metrics:**
- Invocations: 7
- Success rate: 0.0%
- Last used: 2025-10-09 19:16

**Token Consumption:**
- Total tokens: 125,512 (Input: 55, Output: 1,433)
- Cache tokens: 451,724 reads, 124,024 writes
- Avg tokens/invocation: 17930

**Cost Analysis:**
- Estimated cost: $0.6223
- ROI score: 0.06 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.find_file (global scope)

**Usage Metrics:**
- Invocations: 5
- Success rate: 0.0%
- Last used: 2025-10-05 16:59

**Token Consumption:**
- Total tokens: 115,790 (Input: 58, Output: 25)
- Cache tokens: 99,012 reads, 115,707 writes
- Avg tokens/invocation: 23158

**Cost Analysis:**
- Estimated cost: $0.4642
- ROI score: 0.04 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.list_pages (unknown scope)

**Usage Metrics:**
- Invocations: 7
- Success rate: 0.0%
- Last used: 2025-10-09 14:02

**Token Consumption:**
- Total tokens: 105,704 (Input: 78, Output: 1,410)
- Cache tokens: 439,187 reads, 104,216 writes
- Avg tokens/invocation: 15101

**Cost Analysis:**
- Estimated cost: $0.5440
- ROI score: 0.07 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.list_memories (global scope)

**Usage Metrics:**
- Invocations: 2
- Success rate: 0.0%
- Last used: 2025-10-05 16:02

**Token Consumption:**
- Total tokens: 78,590 (Input: 14, Output: 77)
- Cache tokens: 37,212 reads, 78,499 writes
- Avg tokens/invocation: 39295

**Cost Analysis:**
- Estimated cost: $0.3067
- ROI score: 0.03 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.write_memory (global scope)

**Usage Metrics:**
- Invocations: 2
- Success rate: 0.0%
- Last used: 2025-10-05 16:23

**Token Consumption:**
- Total tokens: 73,282 (Input: 52, Output: 1,185)
- Cache tokens: 55,983 reads, 72,045 writes
- Avg tokens/invocation: 36641

**Cost Analysis:**
- Estimated cost: $0.3049
- ROI score: 0.03 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.insert_after_symbol (global scope)

**Usage Metrics:**
- Invocations: 4
- Success rate: 0.0%
- Last used: 2025-10-10 13:44

**Token Consumption:**
- Total tokens: 63,777 (Input: 42, Output: 2,595)
- Cache tokens: 272,331 reads, 61,140 writes
- Avg tokens/invocation: 15944

**Cost Analysis:**
- Estimated cost: $0.3500
- ROI score: 0.06 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.think_about_task_adherence (global scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-05 09:29

**Token Consumption:**
- Total tokens: 53,628 (Input: 4, Output: 47)
- Cache tokens: 22,574 reads, 53,577 writes
- Avg tokens/invocation: 53628

**Cost Analysis:**
- Estimated cost: $0.2084
- ROI score: 0.02 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.take_snapshot (unknown scope)

**Usage Metrics:**
- Invocations: 16
- Success rate: 0.0%
- Last used: 2025-10-08 18:37

**Token Consumption:**
- Total tokens: 47,456 (Input: 192, Output: 1,517)
- Cache tokens: 1,624,823 reads, 45,747 writes
- Avg tokens/invocation: 2966

**Cost Analysis:**
- Estimated cost: $0.6823
- ROI score: 0.34 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### whatsapp.send_message (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-09 15:02

**Token Consumption:**
- Total tokens: 40,667 (Input: 9, Output: 7)
- Cache tokens: 30,384 reads, 40,651 writes
- Avg tokens/invocation: 40667

**Cost Analysis:**
- Estimated cost: $0.1617
- ROI score: 0.02 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.replace_symbol_body (global scope)

**Usage Metrics:**
- Invocations: 3
- Success rate: 0.0%
- Last used: 2025-10-09 20:14

**Token Consumption:**
- Total tokens: 31,170 (Input: 29, Output: 4,824)
- Cache tokens: 162,368 reads, 26,317 writes
- Avg tokens/invocation: 10390

**Cost Analysis:**
- Estimated cost: $0.2198
- ROI score: 0.10 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### whatsapp.mark_community_as_read (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-09 18:58

**Token Consumption:**
- Total tokens: 17,448 (Input: 5, Output: 11)
- Cache tokens: 126,328 reads, 17,432 writes
- Avg tokens/invocation: 17448

**Cost Analysis:**
- Estimated cost: $0.1034
- ROI score: 0.06 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.get_current_config (global scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-09 14:04

**Token Consumption:**
- Total tokens: 13,197 (Input: 9, Output: 187)
- Cache tokens: 27,778 reads, 13,001 writes
- Avg tokens/invocation: 13197

**Cost Analysis:**
- Estimated cost: $0.0599
- ROI score: 0.08 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.type (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-08 18:31

**Token Consumption:**
- Total tokens: 8,959 (Input: 13, Output: 185)
- Cache tokens: 117,616 reads, 8,761 writes
- Avg tokens/invocation: 8959

**Cost Analysis:**
- Estimated cost: $0.0710
- ROI score: 0.11 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.select_page (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-08 18:29

**Token Consumption:**
- Total tokens: 8,095 (Input: 10, Output: 251)
- Cache tokens: 96,133 reads, 7,834 writes
- Avg tokens/invocation: 8095

**Cost Analysis:**
- Estimated cost: $0.0620
- ROI score: 0.12 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.get_symbols_overview (global scope)

**Usage Metrics:**
- Invocations: 8
- Success rate: 0.0%
- Last used: 2025-10-09 18:02

**Token Consumption:**
- Total tokens: 7,438 (Input: 502, Output: 565)
- Cache tokens: 493,035 reads, 6,371 writes
- Avg tokens/invocation: 930

**Cost Analysis:**
- Estimated cost: $0.1818
- ROI score: 1.08 invocations per 1K tokens

#### serena.activate_project (global scope)

**Usage Metrics:**
- Invocations: 8
- Success rate: 0.0%
- Last used: 2025-10-10 12:23

**Token Consumption:**
- Total tokens: 6,773 (Input: 87, Output: 687)
- Cache tokens: 382,330 reads, 5,999 writes
- Avg tokens/invocation: 847

**Cost Analysis:**
- Estimated cost: $0.1478
- ROI score: 1.18 invocations per 1K tokens

#### whatsapp.list_communities (unknown scope)

**Usage Metrics:**
- Invocations: 2
- Success rate: 0.0%
- Last used: 2025-10-09 19:58

**Token Consumption:**
- Total tokens: 2,410 (Input: 8, Output: 312)
- Cache tokens: 186,437 reads, 2,090 writes
- Avg tokens/invocation: 1205

**Cost Analysis:**
- Estimated cost: $0.0685
- ROI score: 0.83 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### serena.insert_before_symbol (global scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-09 19:16

**Token Consumption:**
- Total tokens: 1,494 (Input: 9, Output: 510)
- Cache tokens: 134,481 reads, 975 writes
- Avg tokens/invocation: 1494

**Cost Analysis:**
- Estimated cost: $0.0517
- ROI score: 0.67 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### chrome-devtools.evaluate_script (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-08 18:34

**Token Consumption:**
- Total tokens: 558 (Input: 14, Output: 240)
- Cache tokens: 127,046 reads, 304 writes
- Avg tokens/invocation: 558

**Cost Analysis:**
- Estimated cost: $0.0429
- ROI score: 1.79 invocations per 1K tokens

#### chrome-devtools.fill (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-08 18:31

**Token Consumption:**
- Total tokens: 473 (Input: 14, Output: 129)
- Cache tokens: 126,377 reads, 330 writes
- Avg tokens/invocation: 473

**Cost Analysis:**
- Estimated cost: $0.0411
- ROI score: 2.11 invocations per 1K tokens

#### playwright.browser_navigate (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-08 17:13

**Token Consumption:**
- Total tokens: 412 (Input: 13, Output: 238)
- Cache tokens: 89,683 reads, 161 writes
- Avg tokens/invocation: 412

**Cost Analysis:**
- Estimated cost: $0.0311
- ROI score: 2.43 invocations per 1K tokens

#### chrome-devtools.evaluate (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-10-08 18:34

**Token Consumption:**
- Total tokens: 346 (Input: 14, Output: 158)
- Cache tokens: 126,872 reads, 174 writes
- Avg tokens/invocation: 346

**Cost Analysis:**
- Estimated cost: $0.0411
- ROI score: 2.89 invocations per 1K tokens


### Session Utilization

**Total sessions analyzed**: 361

This section shows how efficiently each MCP server uses context tokens across sessions. Global servers load in ALL sessions (consuming overhead tokens), even when not used.

#### serena (global scope)

**Session Metrics:**
- Utilization rate: 4.2% (15/361 sessions)
- Efficiency: POOR
- ⚠️  Loads in ALL sessions (361 sessions)

**Overhead Analysis:**
- Estimated overhead: ~10,000 tokens per session
- Total wasted overhead: ~3,460,000 tokens (346 unused sessions)
- 🔴 **Action needed**: Consider moving to project-level config to reduce waste

#### sequential-thinking (global scope)

**Session Metrics:**
- Utilization rate: 5.3% (19/361 sessions)
- Efficiency: POOR
- ⚠️  Loads in ALL sessions (361 sessions)

**Overhead Analysis:**
- Estimated overhead: ~500 tokens per session
- Total wasted overhead: ~171,000 tokens (342 unused sessions)
- 🔴 **Action needed**: Consider moving to project-level config to reduce waste


### Recommendations

**HIGH**: serena
   - **Issue**: Server 'serena' loads in all sessions but only used in 4.2% (15/361 sessions)
   - **Action**: Consider moving 'serena' to project-level config. Wasted overhead: ~3,460,000 tokens across 346 sessions

**MEDIUM**: sequential-thinking
   - **Issue**: Server 'sequential-thinking' has low ROI: 305 invocations for 2,489,545 tokens (est. $17.8164)
   - **Action**: Review usage patterns. Consider if 'sequential-thinking' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 24 invocations for 241,241 tokens (est. $1.2144)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 11 invocations for 144,511 tokens (est. $0.6930)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 5 invocations for 115,790 tokens (est. $0.4642)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 7 invocations for 125,512 tokens (est. $0.6223)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 4 invocations for 63,777 tokens (est. $0.3500)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 8 invocations for 194,034 tokens (est. $0.9395)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' has low ROI: 7 invocations for 105,704 tokens (est. $0.5440)
   - **Action**: Review usage patterns. Consider if 'chrome-devtools' is cost-effective (unknown scope)

**MEDIUM**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' has low ROI: 17 invocations for 359,142 tokens (est. $1.8222)
   - **Action**: Review usage patterns. Consider if 'chrome-devtools' is cost-effective (unknown scope)

**MEDIUM**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' has low ROI: 16 invocations for 47,456 tokens (est. $0.6823)
   - **Action**: Review usage patterns. Consider if 'chrome-devtools' is cost-effective (unknown scope)

**MEDIUM**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' has low ROI: 15 invocations for 157,289 tokens (est. $0.9798)
   - **Action**: Review usage patterns. Consider if 'chrome-devtools' is cost-effective (unknown scope)

**MEDIUM**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' has low ROI: 1 invocations for 8,095 tokens (est. $0.0620)
   - **Action**: Review usage patterns. Consider if 'chrome-devtools' is cost-effective (unknown scope)

**MEDIUM**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' has low ROI: 1 invocations for 8,959 tokens (est. $0.0710)
   - **Action**: Review usage patterns. Consider if 'chrome-devtools' is cost-effective (unknown scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 2 invocations for 78,590 tokens (est. $0.3067)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 2 invocations for 73,282 tokens (est. $0.3049)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: whatsapp
   - **Issue**: Server 'whatsapp' has low ROI: 14 invocations for 155,682 tokens (est. $0.8244)
   - **Action**: Review usage patterns. Consider if 'whatsapp' is cost-effective (unknown scope)

**MEDIUM**: whatsapp
   - **Issue**: Server 'whatsapp' has low ROI: 19 invocations for 330,806 tokens (est. $1.5644)
   - **Action**: Review usage patterns. Consider if 'whatsapp' is cost-effective (unknown scope)

**MEDIUM**: whatsapp
   - **Issue**: Server 'whatsapp' has low ROI: 2 invocations for 2,410 tokens (est. $0.0685)
   - **Action**: Review usage patterns. Consider if 'whatsapp' is cost-effective (unknown scope)

**MEDIUM**: whatsapp
   - **Issue**: Server 'whatsapp' has low ROI: 1 invocations for 17,448 tokens (est. $0.1034)
   - **Action**: Review usage patterns. Consider if 'whatsapp' is cost-effective (unknown scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 1 invocations for 1,494 tokens (est. $0.0517)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 3 invocations for 31,170 tokens (est. $0.2198)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: whatsapp
   - **Issue**: Server 'whatsapp' has low ROI: 1 invocations for 40,667 tokens (est. $0.1617)
   - **Action**: Review usage patterns. Consider if 'whatsapp' is cost-effective (unknown scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 1 invocations for 13,197 tokens (est. $0.0599)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: serena
   - **Issue**: Server 'serena' has low ROI: 1 invocations for 53,628 tokens (est. $0.2084)
   - **Action**: Review usage patterns. Consider if 'serena' is cost-effective (global scope)

**MEDIUM**: sequential-thinking
   - **Issue**: Server 'sequential-thinking' loads in all sessions but only used in 5.3% (19/361 sessions)
   - **Action**: Consider moving 'sequential-thinking' to project-level config. Wasted overhead: ~171,000 tokens across 342 sessions

**LOW**: sequential-thinking
   - **Issue**: Server 'sequential-thinking' consumed 2,489,545 tokens (est. $17.82)
   - **Action**: Frequent user: 305 calls, ~8,162 tokens/call (global scope)

**LOW**: serena
   - **Issue**: Server 'serena' consumed 241,241 tokens (est. $1.21)
   - **Action**: Frequent user: 24 calls, ~10,051 tokens/call (global scope)

**LOW**: serena
   - **Issue**: Server 'serena' consumed 144,511 tokens (est. $0.69)
   - **Action**: Frequent user: 11 calls, ~13,137 tokens/call (global scope)

**LOW**: serena
   - **Issue**: Server 'serena' consumed 115,790 tokens (est. $0.46)
   - **Action**: Frequent user: 5 calls, ~23,158 tokens/call (global scope)

**LOW**: serena
   - **Issue**: Server 'serena' consumed 125,512 tokens (est. $0.62)
   - **Action**: Frequent user: 7 calls, ~17,930 tokens/call (global scope)

**LOW**: serena
   - **Issue**: Server 'serena' consumed 194,034 tokens (est. $0.94)
   - **Action**: Frequent user: 8 calls, ~24,254 tokens/call (global scope)

**LOW**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' consumed 105,704 tokens (est. $0.54)
   - **Action**: Frequent user: 7 calls, ~15,100 tokens/call (unknown scope)

**LOW**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' consumed 359,142 tokens (est. $1.82)
   - **Action**: Frequent user: 17 calls, ~21,126 tokens/call (unknown scope)

**LOW**: chrome-devtools
   - **Issue**: Server 'chrome-devtools' consumed 157,289 tokens (est. $0.98)
   - **Action**: Frequent user: 15 calls, ~10,485 tokens/call (unknown scope)

**LOW**: whatsapp
   - **Issue**: Server 'whatsapp' consumed 155,682 tokens (est. $0.82)
   - **Action**: Frequent user: 14 calls, ~11,120 tokens/call (unknown scope)

**LOW**: whatsapp
   - **Issue**: Server 'whatsapp' consumed 330,806 tokens (est. $1.56)
   - **Action**: Frequent user: 19 calls, ~17,410 tokens/call (unknown scope)


---
*MCP analytics auto-generated by claude-nixos-automation*
*Next update: On next rebuild or weekly*
