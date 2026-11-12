#!/usr/bin/env python3
import json
import shlex
import subprocess
import sys
from os import environ
from pathlib import Path

AGENT_COMMAND = "claude"
SETUP_SCRIPT_SUFFIX = ".sh"


def find_setup_script(config_dir, repo_name):
    setup_script = config_dir / f"{repo_name}{SETUP_SCRIPT_SUFFIX}"
    return setup_script if setup_script.is_file() else None


def agent_pane_command(setup_script):
    if setup_script is None:
        return AGENT_COMMAND
    return f"source {shlex.quote(str(setup_script))} && {AGENT_COMMAND}"


def main(env, run):
    event = json.loads(env["HERDR_PLUGIN_EVENT_JSON"])
    worktree = event["data"]["workspace"]["worktree"]
    herdr = env["HERDR_BIN_PATH"]
    agent_pane = env["HERDR_PANE_ID"]
    setup_script = find_setup_script(
        Path(env["HERDR_PLUGIN_CONFIG_DIR"]), worktree["repo_name"]
    )

    run([herdr, "pane", "run", agent_pane, agent_pane_command(setup_script)])


def run_checked(command):
    subprocess.run(command, check=True, stdout=subprocess.DEVNULL)


if __name__ == "__main__":
    sys.exit(main(environ, run_checked))
