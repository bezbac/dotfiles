from pathlib import Path
import subprocess

from crit_memory.diffs import changed_contexts, git_diff


def git(repo: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args], cwd=repo, check=True, capture_output=True, text=True
    )
    return result.stdout


def initialized_repo(tmp_path: Path) -> Path:
    git(tmp_path, "init", "--quiet")
    git(tmp_path, "config", "user.name", "Test")
    git(tmp_path, "config", "user.email", "test@example.com")
    git(tmp_path, "config", "commit.gpgsign", "false")
    (tmp_path / "unstaged.txt").write_text("before\n")
    (tmp_path / "staged.txt").write_text("before\n")
    git(tmp_path, "add", ".")
    git(tmp_path, "commit", "--quiet", "-m", "Initial")
    return tmp_path


def test_parses_changed_hunk_using_local_source(tmp_path: Path) -> None:
    source = tmp_path / "example.py"
    source.write_text("def calculate():\n    return 2\n")
    patch = """diff --git a/example.py b/example.py
--- a/example.py
+++ b/example.py
@@ -1,2 +1,2 @@
 def calculate():
-    return 1
+    return 2
"""

    contexts = changed_contexts(patch, tmp_path)

    assert len(contexts) == 1
    assert contexts[0].path == "example.py"
    assert contexts[0].context.symbol == "calculate"
    assert "return 2" in contexts[0].context.text


def test_deleted_only_external_hunk_keeps_removed_code(tmp_path: Path) -> None:
    patch = """diff --git a/old.txt b/old.txt
--- a/old.txt
+++ /dev/null
@@ -1,2 +0,0 @@
-unsafe old code
-another line
"""

    assert changed_contexts(patch, tmp_path) == []


def test_external_patch_without_local_file_uses_hunk(tmp_path: Path) -> None:
    patch = """diff --git a/new.ts b/new.ts
--- a/new.ts
+++ b/new.ts
@@ -0,0 +1,2 @@
+function run() {
+  return true
"""

    contexts = changed_contexts(patch, tmp_path)

    assert contexts[0].context.text == "function run() {\n  return true"


def test_working_tree_diff_includes_staged_unstaged_and_untracked(
    tmp_path: Path, monkeypatch
) -> None:
    repo = initialized_repo(tmp_path)
    (repo / "unstaged.txt").write_text("unstaged change\n")
    (repo / "staged.txt").write_text("staged change\n")
    git(repo, "add", "staged.txt")
    (repo / "untracked.txt").write_text("untracked change\n")
    monkeypatch.chdir(repo)

    patch = git_diff(None, [])

    assert "b/unstaged.txt" in patch
    assert "b/staged.txt" in patch
    assert "b/untracked.txt" in patch


def test_working_tree_diff_respects_path_scope(tmp_path: Path, monkeypatch) -> None:
    repo = initialized_repo(tmp_path)
    (repo / "unstaged.txt").write_text("include\n")
    (repo / "staged.txt").write_text("exclude\n")
    (repo / "untracked.txt").write_text("exclude\n")
    monkeypatch.chdir(repo)

    patch = git_diff(None, ["unstaged.txt"])

    assert "b/unstaged.txt" in patch
    assert "b/staged.txt" not in patch
    assert "b/untracked.txt" not in patch


def test_git_range_diff(tmp_path: Path, monkeypatch) -> None:
    repo = initialized_repo(tmp_path)
    (repo / "unstaged.txt").write_text("committed change\n")
    git(repo, "add", "unstaged.txt")
    git(repo, "commit", "--quiet", "-m", "Change")
    (repo / "untracked.txt").write_text("not in range\n")
    monkeypatch.chdir(repo)

    patch = git_diff("HEAD~1..HEAD", [])

    assert "b/unstaged.txt" in patch
    assert "b/untracked.txt" not in patch
