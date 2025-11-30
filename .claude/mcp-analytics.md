---
status: active
created: 2025-11-30
updated: 2025-11-30
type: reference
lifecycle: persistent
---

## 🔌 MCP Server Status

**Last Updated**: 2025-11-30 19:46:07
**Analysis Period**: 30 days

### Configured Servers (1)

**1. playwright** ✓ CONNECTED
   - **Type**: unknown
   - **Command**: `bash -c cd ~/birthday-manager && devenv shell -- mcp-server-playwright --extension --browser chrome --executable-path /run/current-system/sw/bin/google-chrome-stable`
   - **Location**: global (~/.claude.json)

### Connection Health

- ✅ **Connected**: 1 server(s)
  - playwright


### Usage Analytics

**Total MCP invocations**: 54
**Total tokens consumed**: 476,251
**Estimated total cost**: $3.2645

#### playwright.browser_take_screenshot (global scope)

**Usage Metrics:**
- Invocations: 19
- Success rate: 0.0%
- Last used: 2025-11-21 00:16

**Token Consumption:**
- Total tokens: 153,758 (Input: 207, Output: 3,603)
- Cache tokens: 1,792,280 reads, 149,948 writes
- Avg tokens/invocation: 8093

**Cost Analysis:**
- Estimated cost: $1.1547
- ROI score: 0.12 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_navigate (global scope)

**Usage Metrics:**
- Invocations: 15
- Success rate: 0.0%
- Last used: 2025-11-27 11:47

**Token Consumption:**
- Total tokens: 141,533 (Input: 301, Output: 2,818)
- Cache tokens: 1,142,813 reads, 138,414 writes
- Avg tokens/invocation: 9436

**Cost Analysis:**
- Estimated cost: $0.9051
- ROI score: 0.11 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### sequential-thinking.sequentialthinking (unknown scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-11-06 08:04

**Token Consumption:**
- Total tokens: 110,531 (Input: 9, Output: 2)
- Cache tokens: 34,764 reads, 110,520 writes
- Avg tokens/invocation: 110531

**Cost Analysis:**
- Estimated cost: $0.4249
- ROI score: 0.01 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_evaluate (global scope)

**Usage Metrics:**
- Invocations: 11
- Success rate: 0.0%
- Last used: 2025-11-06 23:03

**Token Consumption:**
- Total tokens: 41,066 (Input: 110, Output: 166)
- Cache tokens: 1,141,316 reads, 40,790 writes
- Avg tokens/invocation: 3733

**Cost Analysis:**
- Estimated cost: $0.4982
- ROI score: 0.27 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_click (global scope)

**Usage Metrics:**
- Invocations: 3
- Success rate: 0.0%
- Last used: 2025-11-18 23:02

**Token Consumption:**
- Total tokens: 19,485 (Input: 36, Output: 607)
- Cache tokens: 126,161 reads, 18,842 writes
- Avg tokens/invocation: 6495

**Cost Analysis:**
- Estimated cost: $0.1177
- ROI score: 0.15 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_network_requests (global scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-11-18 23:02

**Token Consumption:**
- Total tokens: 3,350 (Input: 14, Output: 225)
- Cache tokens: 41,683 reads, 3,111 writes
- Avg tokens/invocation: 3350

**Cost Analysis:**
- Estimated cost: $0.0276
- ROI score: 0.30 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_close (global scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-11-18 21:58

**Token Consumption:**
- Total tokens: 3,177 (Input: 10, Output: 366)
- Cache tokens: 50,944 reads, 2,801 writes
- Avg tokens/invocation: 3177

**Cost Analysis:**
- Estimated cost: $0.0313
- ROI score: 0.31 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_install (global scope)

**Usage Metrics:**
- Invocations: 2
- Success rate: 0.0%
- Last used: 2025-11-27 11:47

**Token Consumption:**
- Total tokens: 2,663 (Input: 14, Output: 105)
- Cache tokens: 220,306 reads, 2,544 writes
- Avg tokens/invocation: 1332

**Cost Analysis:**
- Estimated cost: $0.0772
- ROI score: 0.75 invocations per 1K tokens
- ⚠️  **Low efficiency** - Consider reviewing usage patterns

#### playwright.browser_snapshot (global scope)

**Usage Metrics:**
- Invocations: 1
- Success rate: 0.0%
- Last used: 2025-11-06 22:52

**Token Consumption:**
- Total tokens: 688 (Input: 13, Output: 144)
- Cache tokens: 78,764 reads, 531 writes
- Avg tokens/invocation: 688

**Cost Analysis:**
- Estimated cost: $0.0278
- ROI score: 1.45 invocations per 1K tokens


### Session Utilization

**Total sessions analyzed**: 288

This section shows how efficiently each MCP server uses context tokens across sessions. Global servers load in ALL sessions (consuming overhead tokens), even when not used.

#### playwright (global scope)

**Session Metrics:**
- Utilization rate: 3.1% (9/288 sessions)
- Efficiency: POOR
- ⚠️  Loads in ALL sessions (288 sessions)

**Overhead Analysis:**
- Estimated overhead: ~4,000 tokens per session
- Total wasted overhead: ~1,116,000 tokens (279 unused sessions)
- 🔴 **Action needed**: Consider moving to project-level config to reduce waste


### Recommendations

**HIGH**: playwright
   - **Issue**: Server 'playwright' loads in all sessions but only used in 3.1% (9/288 sessions)
   - **Action**: Consider moving 'playwright' to project-level config. Wasted overhead: ~1,116,000 tokens across 279 sessions

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 15 invocations for 141,533 tokens (est. $0.9051)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 2 invocations for 2,663 tokens (est. $0.0772)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**MEDIUM**: sequential-thinking
   - **Issue**: Server 'sequential-thinking' has low ROI: 1 invocations for 110,531 tokens (est. $0.4249)
   - **Action**: Review usage patterns. Consider if 'sequential-thinking' is cost-effective (unknown scope)

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 19 invocations for 153,758 tokens (est. $1.1547)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 1 invocations for 3,350 tokens (est. $0.0276)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 3 invocations for 19,485 tokens (est. $0.1177)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 11 invocations for 41,066 tokens (est. $0.4982)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**MEDIUM**: playwright
   - **Issue**: Server 'playwright' has low ROI: 1 invocations for 3,177 tokens (est. $0.0313)
   - **Action**: Review usage patterns. Consider if 'playwright' is cost-effective (global scope)

**LOW**: playwright
   - **Issue**: Server 'playwright' consumed 141,533 tokens (est. $0.91)
   - **Action**: Frequent user: 15 calls, ~9,435 tokens/call (global scope)

**LOW**: sequential-thinking
   - **Issue**: Server 'sequential-thinking' consumed 110,531 tokens (est. $0.42)
   - **Action**: Frequent user: 1 calls, ~110,531 tokens/call (unknown scope)

**LOW**: playwright
   - **Issue**: Server 'playwright' consumed 153,758 tokens (est. $1.15)
   - **Action**: Frequent user: 19 calls, ~8,092 tokens/call (global scope)


---
*MCP analytics auto-generated by claude-nixos-automation*
*Next update: On next rebuild or weekly*
