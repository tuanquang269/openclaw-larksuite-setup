# OpenClaw & LarkSuite Setup (Agent Skill)

This repository contains a reusable **Agent Skill** formatted to the [AgentSkills.io](https://agentskills.io) standard. It is designed to be given to an autonomous AI agent to perform complex setup tasks reliably.

## What this skill does

When an AI Agent is equipped with this skill, it gains the ability to:
1. **Install OpenClaw** safely via the terminal (bypassing versioning bugs)
2. **Configure any LLM provider** (Kimi, Claude, OpenAI, Qwen, etc.) dynamically based on user requests, including auto-configuring fallback models.
3. **Connect a LarkSuite/Feishu bot** completely via the terminal. It handles the `openclaw channels login` process and instructs the user to scan the generated QR code, making the setup nearly frictionless.

## Repository Structure

- `SKILL.md`: The core metadata and step-by-step Meta-Prompt for the AI agent.
- `scripts/boot-healthcheck.sh`: A supporting watchdog script that the agent installs to ensure the OpenClaw gateway stays alive, complete with a startup grace period.

## How to use

If you are a user interacting with an AI Agent (like Claude, ChatGPT, or an autonomous coding agent):
1. Provide the agent with the contents of `SKILL.md` (or point it to this repository).
2. Say: *"Please use the openclaw-larksuite-setup skill to install my agent and configure it with [Your Model Choice]"*.

The agent will read the skill instructions and autonomously execute the terminal commands, prompt you for API keys if necessary, and generate the QR code for you to scan.
