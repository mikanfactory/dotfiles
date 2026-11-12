import importlib.machinery
import importlib.util
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
MODIFY_PATH = REPO_ROOT / "home/dot_claude/modify_settings.json"

loader = importlib.machinery.SourceFileLoader("modify_settings", str(MODIFY_PATH))
spec = importlib.util.spec_from_loader("modify_settings", loader)
modify_settings = importlib.util.module_from_spec(spec)
loader.exec_module(modify_settings)


class HerdrOverlayTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(tmp.name)

    def install_hook_script(self):
        hook_script = self.home / ".claude" / "hooks" / "herdr-agent-state.sh"
        hook_script.parent.mkdir(parents=True)
        hook_script.write_text("#!/bin/bash\n")
        return hook_script

    def test_is_empty_when_herdr_integration_is_not_installed(self):
        self.assertEqual(modify_settings.herdr_overlay(self.home), {})

    def test_registers_session_start_hook_exactly_as_herdr_writes_it(self):
        hook_script = self.install_hook_script()

        self.assertEqual(
            modify_settings.herdr_overlay(self.home),
            {
                "hooks": {
                    "SessionStart": [
                        {
                            "matcher": "^(startup|resume|clear|compact|fork)$",
                            "hooks": [
                                {
                                    "type": "command",
                                    "command": f"bash '{hook_script}' session",
                                    "timeout": 10,
                                }
                            ],
                        }
                    ]
                }
            },
        )

    def test_keeps_existing_hooks_when_merged(self):
        self.install_hook_script()
        base = {"hooks": {"Stop": [{"hooks": []}]}}

        merged = modify_settings.deep_merge(
            base, modify_settings.herdr_overlay(self.home)
        )

        self.assertEqual(sorted(merged["hooks"]), ["SessionStart", "Stop"])


if __name__ == "__main__":
    unittest.main()
