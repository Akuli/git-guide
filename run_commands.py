import pathlib
import re
import subprocess
import sys
import tempfile


if sys.platform == 'win32':
    raise RuntimeError("Windows is not supported yet. Sorry.")


class CommandRunner:

    def __init__(self, tempdir):
        self.working_dir = tempdir / 'working_dir'
        self.fake_github_dir = tempdir / 'fake_github' / 'reponame'
        self.working_dir.mkdir()

    def run_command(self, bash_command):
        if bash_command == 'git clone https://github.com/username/reponame':
            # Actual 'git clone' output changes depending on whether you clone
            # a directory on your computer or a github repo. We want to show
            # what would happen if you cloned a github repo.
            subprocess.run(['git', 'clone', '-q', self.fake_github_dir, self.working_dir / 'reponame'], check=True)
            return '''\
Cloning into 'reponame'...
remote: Enumerating objects: 6, done.
remote: Total 6 (delta 0), reused 0 (delta 0), pack-reused 6
Unpacking objects: 100% (6/6), done.
'''

        if bash_command.startswith('cd '):
            self.working_dir /= bash_command[3:]
            return ''

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
        #
        # This thing doesn't work on Windows. I'm sorry.
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
        return output.decode('utf-8')

    def add_outputs_to_commands(self, regex_match):
        commands = [
            line.lstrip('$').strip()
            for line in regex_match.group(0).split('\n')
            if line.startswith('$')
        ]
        outputs = [self.run_command(command) for command in commands]
        commands_and_outputs = '\n'.join(
            f"$ {command}\n{output}"
            for command, output in zip(commands, outputs)
        )
        return f'```sh\n{commands_and_outputs}```\n'


with tempfile.TemporaryDirectory() as tempdir_string:
    tempdir = pathlib.Path(tempdir_string)
    # Simulate with github does when you create empty repo
    (tempdir / 'fake_github' / 'reponame').mkdir(parents=True)
    (tempdir / 'fake_github' / 'reponame' / 'README.md').touch()
    (tempdir / 'fake_github' / 'reponame' / 'LICENSE').touch()
    (tempdir / 'fake_github' / 'reponame' / '.gitignore').touch()
    subprocess.run(
        'git init -q && git add . && git commit -q -m "Initial commit"',
        shell=True,
        check=True,
        cwd=(tempdir / 'fake_github' / 'reponame'),
    )

    (tempdir / 'cloned' / 'reponame').mkdir(parents=True)
    runner = CommandRunner(tempdir)

    for filename in ['getting-started.md']:
        path = pathlib.Path(filename)
        content = path.read_text()
        content = re.sub(r'```sh\n(([^`].*)?\n)+```\n', runner.add_outputs_to_commands, content)
        path.write_text(content)
