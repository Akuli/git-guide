import time
import atexit
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile


class CommandRunner:

    def __init__(self, tempdir):
        self.working_dir = tempdir / 'working_dir'
        self.fake_github_dir = tempdir / 'fake_github' / 'reponame'
        self.git_config = {
            'core.pager': 'cat',
            'core.editor': 'true',  # Don't change commit message (for merge commits)
            # Ensure we get same error as with freshly installed git
            'user.email': '',
            'user.name': '',
        }
        self.working_dir.mkdir()

    def run_command(self, bash_command):
        print("  ", bash_command)
        if bash_command == 'git clone https://github.com/username/reponame':
            subprocess.run(
                ['git', 'clone', '-q', self.fake_github_dir, self.working_dir / 'reponame'],
                check=True,
            )

            for name, value in self.git_config.items():
                subprocess.run(
                    ['git', 'config', name, value],
                    cwd=(self.working_dir / 'reponame'),
                    check=True,
                )
            return None  # not used

        if bash_command.startswith('cd '):
            self.working_dir /= bash_command[3:]
            return ''  # No output

        # For example:  git config --global user.name "yourusername"
        bash_command = bash_command.replace('--global', '')

        # Make sure commit timestamps differ. Otherwise the output order of
        # 'git log --oneline --graph --all' can vary randomly.
#        if bash_command.startswith('git commit'):
#            time.sleep(1)

        # Many programs display their output differently when they think the
        # output is going to a terminal. For this guide, we generally want
        # programs to think so. For example:
        #  - 'ls' should show file names separated by two spaces, not one file per line
        #  - 'git log --all --pretty --oneline' should show * on the left side of
        #    commit hashes, just like it does on terminal
        #
        #
        # The pty module creates pseudo-TTYs, which are essentially fake
        # terminals. But for some reason, the output still goes to the real
        # terminal, so I have to do it in a subprocess and capture its output.
        args = ['bash', '-c', bash_command]
        output = subprocess.run(
            [sys.executable, '-c', f'import pty; pty.spawn({str(args)})'],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            cwd=self.working_dir,
        ).stdout
        output = output.expandtabs(8)
        output = re.sub(rb"\x1b\[[0-9;]*m", b"", output)  # https://superuser.com/a/380778
        output = output.replace(b'\r\n', b'\n')  # no idea why needed
        output = re.sub(rb'.*\r\x1b\[K', b'', output)  # the weird characters seem to mean "forget prev line"
        return output.decode('utf-8')


def create_runner():
    tempdir = pathlib.Path(tempfile.mkdtemp())
    atexit.register(lambda: shutil.rmtree(tempdir))

    # Simulate with github does when you create empty repo
    (tempdir / 'fake_github' / 'reponame').mkdir(parents=True)
    (tempdir / 'fake_github' / 'reponame' / 'README.md').write_text(
        "# reponame\nThe description of the repository is here by default\n"
    )
    (tempdir / 'fake_github' / 'reponame' / 'LICENSE').touch()
    (tempdir / 'fake_github' / 'reponame' / '.gitignore').touch()
    subprocess.run(
        '''
        set -e
        git init -q
        git config user.email "you@example.com"
        git config user.name "yourusername"
        git checkout -q -b main
        git add .
        git commit -q -m "Initial commit"
        git config receive.denyCurrentBranch ignore
        ''',
        shell=True,
        check=True,
        cwd=(tempdir / 'fake_github' / 'reponame'),
    )
    return CommandRunner(tempdir)
