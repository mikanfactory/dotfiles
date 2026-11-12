import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
HOOK_PATH = (
    REPO_ROOT
    / "home/dot_config/herdr/local-plugins/worktree-setup/on_worktree_created.py"
)

spec = importlib.util.spec_from_file_location("on_worktree_created", HOOK_PATH)
hook = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hook)

PANE_ID = "w5:p1"
HERDR_BIN = "/opt/bin/herdr"


def build_env(config_dir, repo_name="datahub"):
    event = {
        "event": "worktree_created",
        "data": {
            "workspace": {
                "worktree": {"repo_name": repo_name}
            }
        },
    }
    return {
        "HERDR_BIN_PATH": HERDR_BIN,
        "HERDR_PANE_ID": PANE_ID,
        "HERDR_PLUGIN_CONFIG_DIR": str(config_dir),
        "HERDR_PLUGIN_EVENT_JSON": json.dumps(event),
    }


class OnWorktreeCreatedTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.config_dir = Path(tmp.name)
        self.calls = []

    def run_hook(self, env):
        hook.main(env, self.calls.append)

    def test_does_not_split_the_agent_pane(self):
        self.run_hook(build_env(self.config_dir))

        self.assertEqual([call[1:3] for call in self.calls], [["pane", "run"]])

    def test_starts_agent_directly_when_repo_has_no_setup_script(self):
        self.run_hook(build_env(self.config_dir))

        self.assertEqual(
            self.calls[0], [HERDR_BIN, "pane", "run", PANE_ID, hook.AGENT_COMMAND]
        )

    def test_sources_setup_script_before_agent_when_repo_has_one(self):
        setup_script = self.config_dir / "datahub.sh"
        setup_script.write_text("mise trust\n")

        self.run_hook(build_env(self.config_dir))

        self.assertEqual(
            self.calls[0],
            [
                HERDR_BIN,
                "pane",
                "run",
                PANE_ID,
                f"source {setup_script} && {hook.AGENT_COMMAND}",
            ],
        )

    def test_ignores_setup_scripts_of_other_repos(self):
        (self.config_dir / "datahub.sh").write_text("mise trust\n")

        self.run_hook(build_env(self.config_dir, repo_name="dotfiles"))

        self.assertEqual(
            self.calls[0], [HERDR_BIN, "pane", "run", PANE_ID, hook.AGENT_COMMAND]
        )

    def test_quotes_setup_script_path_containing_spaces(self):
        config_dir = self.config_dir / "with space"
        config_dir.mkdir()
        (config_dir / "datahub.sh").write_text("mise trust\n")

        self.run_hook(build_env(config_dir))

        self.assertEqual(
            self.calls[0][-1],
            f"source '{config_dir}/datahub.sh' && {hook.AGENT_COMMAND}",
        )

    def test_works_when_config_dir_does_not_exist(self):
        self.run_hook(build_env(self.config_dir / "missing"))

        self.assertEqual(self.calls[0][-1], hook.AGENT_COMMAND)


if __name__ == "__main__":
    unittest.main()
