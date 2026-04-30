---
name: openclaw-larksuite-setup
description: "Use this skill to install and configure the OpenClaw AI agent system via the terminal, configure it with ANY language model provider (Kimi, Qwen, Claude, OpenAI, etc.), and connect it to a LarkSuite/Feishu bot channel using a simple QR code workflow. Trigger this when a user asks to 'setup OpenClaw', 'install openclaw with lark', or 'connect openclaw to feishu'."
---

# OpenClaw & LarkSuite Setup Workflow

This skill guides you (the AI Agent) to autonomously set up OpenClaw for the user. OpenClaw is a locally hosted gateway that bridges LLM APIs with messaging platforms. 

## 🎯 Core Objectives
1. **Unrestricted Installation:** Install OpenClaw via the terminal smoothly, bypassing version mismatches.
2. **Universal LLM Setup:** Configure `openclaw.json` to use any provider API the user requests (Kimi, Qwen, Claude, OpenAI, Ollama, etc.) with proper fallback logic.
3. **Frictionless LarkSuite Connection:** Connect the agent to LarkSuite (Feishu) via terminal QR code without requiring manual app creation in the Developer Console.

## 🏆 Optimal Methodology
- **Installation:** Use the official `npm install -g openclaw@latest` instead of manual binaries to ensure cross-platform compatibility and avoid versioning crashes.
- **Provider Configuration:** Modify `~/.openclaw/openclaw.json` directly to set the API keys and primary/fallback models, rather than relying solely on the interactive UI.
- **LarkSuite Login:** Use the built-in CLI wizard (`openclaw channels login --channel feishu`). This generates a terminal QR code that the user simply scans with their Lark app to automatically provision the bot and WebSocket events.

## 📋 Execution Plan (Step-by-Step for the Agent)

### Phase 1: Environment & Installation
1. **Check Prerequisites:** Run `node -v` to ensure Node.js >= 22 is installed. If not, instruct the user to install it or use homebrew (`brew install node`).
2. **Install OpenClaw:** 
   Run `npm install -g openclaw@latest` in the terminal.
   Verify installation with `openclaw --version`.
3. **Initialize Configuration:**
   If `~/.openclaw/openclaw.json` doesn't exist, run `openclaw init` or start the gateway once (`openclaw gateway start`) to generate the default configuration structure.

### Phase 2: Universal Model Configuration
1. **Identify User's LLM Choice:** Determine which API provider the user wants (e.g., Kimi, Claude, OpenAI). Ask for the API key if not provided.
2. **Edit `openclaw.json`:** Modify the `agents.defaults` section directly using a script or terminal tool.
   *   **Set Primary Model:** Update `"primary": "provider-name/model-name"`.
   *   **Set Fallbacks:** Always configure an array of `"fallbacks": ["provider/fallback-model"]` to prevent silent crashes if the primary model fails.
   *   **Add Auth Profile:** Ensure the API key is injected into the configuration or the environment variables as required by OpenClaw's auth provider schema.

### Phase 3: Frictionless LarkSuite (Feishu) Connection
1. **Initiate QR Code Login:** 
   Run the following command in the terminal to start the wizard:
   ```bash
   openclaw channels login --channel feishu
   ```
2. **Instruct the User:** 
   Tell the user: *"A QR code (or a link to one) has been generated in the terminal. Please open your LarkSuite/Feishu mobile app, scan the QR code, and authorize the bot creation."*
3. **Wait for Completion:** Monitor the terminal output or wait for the user to confirm they have scanned it.
4. **Ensure WebSocket Mode:** Verify that the `channels.feishu.connectionMode` in `openclaw.json` is set to `"websocket"`.

### Phase 4: Gateway Startup & Watchdog
1. **Restart the Gateway:** 
   Run `launchctl stop ai.openclaw.gateway && launchctl start ai.openclaw.gateway` (on macOS) or `openclaw gateway restart`.
2. **Verify Stability:** 
   Check the logs (`tail -20 ~/.openclaw/logs/gateway.log`) to ensure:
   - The provider loaded correctly.
   - The `feishu[default]: WebSocket client started` and `ws client ready` messages appear.
3. **Test the Connection:** Instruct the user to send a direct message (DM) to their newly created bot on LarkSuite to confirm 2-way communication.

## 💻 Example Configuration (`openclaw.json` snippet)

When modifying the configuration for models, ensure the structure looks like this:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/gpt-4o",
        "fallbacks": [
          "anthropic/claude-3-haiku-20240307",
          "ollama/llama3"
        ]
      }
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "connectionMode": "websocket",
      "dmPolicy": "open",
      "groupPolicy": "allowlist"
    }
  }
}
```

## ⚠️ Important Edge Cases & Troubleshooting
- **No Events Arriving:** If the gateway says "ws client ready" but the bot ignores messages, instruct the user to open the [Lark Developer Console](https://open.larksuite.com/app), select their App, go to **Events and Callbacks**, and ensure `im.message.receive_v1` is added to the subscribed events.
- **Gateway Restart Loops:** If you build custom watchdog scripts (`boot-healthcheck.sh`), **always include a 90-second startup grace period**. The Feishu channel WebSocket takes ~35 seconds to fully initialize; an impatient healthcheck will kill it before it connects.
