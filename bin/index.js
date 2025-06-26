#!/usr/bin/env node
const chalk = require("chalk");
const fetch = require("node-fetch");

const server = require("../lib/server");

const authToken = process.argv[2] || process.env.MCP_AUTH_TOKEN;

if (!authToken) {
  console.error(chalk.red("Error: Authentication token is required"));
  process.exit(1);
}

server
  .start(authToken)
  .then(async ({ host, port, protocol }) => {
    console.log(
      chalk.green(`✓ MCP runner server running on ${protocol}://${host}:${port}`)
    );

    const startupPayload = {
      mcpServers: {
        tnt_gdrive: {
          command: "npx",
          args: ["@modelcontextprotocol/server-gdrive"],
          env: {
            GOOGLE_APPLICATION_CREDENTIALS: "/app/credentials/tnt-folder-credentials.json"
          }
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
        console.log(chalk.green("✓ Successfully started MCP clients"));
      } else {
        console.error(
          chalk.red("✖ Failed to start some MCP clients:\n"),
          data.errors || data
        );
      }
    } catch (err) {
      console.error(
        chalk.red("✖ Error bootstrapping clients after server start:\n"),
        err
      );
    }
  })
  .catch((err) => {
    console.error(chalk.red(`Error starting MCP server: ${err.message}`));
    process.exit(1);
  });
