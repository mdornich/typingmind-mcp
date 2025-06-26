#!/usr/bin/env node
const chalk = require("chalk");
const fetch = require("node-fetch");
const fs = require("fs");
const path = require("path");
const server = require("../lib/server");

const authToken = process.argv[2] || process.env.MCP_AUTH_TOKEN;
const credentialsPath = "/app/credentials/tnt-folder-credentials.json";

if (!authToken) {
  console.error(chalk.red("❌ Error: Authentication token is required"));
  process.exit(1);
}

// Check credentials file exists
if (!fs.existsSync(credentialsPath)) {
  console.error(chalk.red(`❌ Credentials file not found at ${credentialsPath}`));
  process.exit(1);
}

// Optional: Show partial credential content for sanity
console.log(chalk.blue("📄 Credential file loaded:"));
try {
  const raw = fs.readFileSync(credentialsPath, "utf8");
  const parsed = JSON.parse(raw);
  console.log("  → client_email:", parsed.client_email);
  console.log("  → project_id:", parsed.project_id);
} catch (err) {
  console.error(chalk.red("❌ Failed to parse credentials file"), err);
  process.exit(1);
}

// Start server
server
  .start(authToken)
  .then(async ({ host, port, protocol }) => {
    console.log(chalk.green(`✅ MCP runner server running at ${protocol}://${host}:${port}`));

    const startupPayload = {
      mcpServers: {
        tnt_gdrive: {
          command: "npx",
          args: [
            "-y",
            "@modelcontextprotocol/server-gdrive",
            "--id",
            "tnt_gdrive",
            "--folderId",
            "1T9Jdvoo5H-TYQFZ6g9sLGfEUBi_EYSEf",
            "--credentials",
            credentialsPath
          ]
        }
      }
    };

    try {
      const response = await fetch(`${protocol}://${host}:${port}/start`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${authToken}`
        },
        body: JSON.stringify(startupPayload)
      });

      const data = await response.json();
      if (response.ok) {
        console.log(chalk.green("🎉 Successfully started MCP clients"));
      } else {
        console.error(chalk.red("❌ Failed to start some MCP clients:\n"), data.errors || data);
      }
    } catch (err) {
      console.error(chalk.red("❌ Error bootstrapping clients after server start:\n"), err);
    }
  })
  .catch((err) => {
    console.error(chalk.red(`❌ Error starting MCP server: ${err.message}`));
    process.exit(1);
  });
