{ inputs, username, ... }:
{
  imports = [ inputs.ensemble.nixosModules.default ];

  # A hub of my own, run as me from ~/.config/ensemble/hub/. Every setting is
  # declared here and merged into hub.yaml when it starts; accounts, tokens and
  # the vault stay in that folder, and the keys the backends name in its .env.
  services.ensemble.hub = {
    enable = true;
    user = username;
    settings = {
      version = 1;
      owner = "Khachatur";

      # The core.
      http.listen = "127.0.0.1:7700";
      llm.direct.backends = {
        central = {
          type = "openai-compatible-api";
          base_url = "http://127.0.0.1:8888/v1";
          api_key_env = "CENTRAL_API_KEY";
          timeout_seconds = 300;
        };
        claude = {
          type = "anthropic-api";
          base_url = "https://api.anthropic.com";
          api_key_env = "ANTHROPIC_API_KEY";
          timeout_seconds = 120;
        };
      };
      accounts = {
        registration = {
          type = "approval";
          max_pending = 20;
        };
        sessions.hours = 12;
        lockout = {
          failures = 5;
          minutes = 15;
        };
        roles = {
          admin = [ "admin" "share" "recall" "tasks" "compute" "host" ];
          member = [ "share" "recall" "tasks" "compute" ];
          reader = [ "recall" ];
        };
      };

      # Everything else: each connector always on.
      connectors = {
        rest = { };
        mcp = { };
        runners = { };
        knowledge = {
          vault = "vault";
          distill = {
            try = [
              {
                backend = "central";
                model = "unsloth/Qwen3.5-9B-GGUF";
              }
              {
                backend = "claude";
                model = "claude-haiku-4-5";
              }
            ];
            when_none = "wait";
            max_tokens = 4000;
          };
          recall = {
            max_notes = 8;
            max_chars = 6000;
          };
        };
        tasks.trackers.issues = {
          type = "local_markdown";
          dir = "issues";
          label = "ensemble";
          poll_seconds = 30;
        };
        sources.adapters = { };
      };
    };
  };
}
