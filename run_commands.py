import hashlib
import pathlib
import re
import subprocess
import sys
import tempfile


class CommandRunner:

    def __init__(self, tempdir):
        self.working_dir = tempdir / 'working_dir'
        self.fake_github_dir = tempdir / 'fake_github' / 'reponame'
        self.git_config = {
            'core.pager': 'cat',
            'core.editor': tempdir / 'fake_editor',
            # Ensure we get same error as with freshly installed git
            'user.email': '',
            'user.name': '',
        }
        self.working_dir.mkdir()

    # Git commit hashes are different every time this script runs. Maybe they
    # include some kind of UUID or system time, idk. But we want consistent output.
    def substitute_commit_hashes(self, git_output):
        git_log = subprocess.check_output(['git', 'log', '--format=%h %s'], cwd=self.working_dir)
        for line in git_log.splitlines():
            actual_hash, first_line_of_commit_message = line.split(maxsplit=1)
            fake_hash = hashlib.md5(first_line_of_commit_message).hexdigest()[:7]
            git_output = git_output.replace(actual_hash.decode('ascii'), fake_hash)
        return git_output

    def run_command(self, bash_command):
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

            # Actual 'git clone' output changes depending on whether you clone
            # a directory on your computer or a github repo. We want to show
            # what would happen if you cloned a github repo.
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
        args = ['bash', '-c', bash_command]
        response = subprocess.run(
            [sys.executable, '-c', f'import pty; pty.spawn({str(args)})'],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            cwd=self.working_dir,
        )

        if bash_command.startswith('git push'):
            # fake output that looks like pushing to github, not like pushing
            # to repo on the same computer
            response.check_returncode()
            output = b'''\
Username for 'https://github.com': username
Password for 'https://username@github.com':
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 184 bytes | 184.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To https://github.com/username/reponame
''' + response.stdout.splitlines(keepends=True)[-1]
        else:
            output = response.stdout

        output = output.expandtabs(8)
        output = re.sub(rb"\x1b\[[0-9;]*m", b"", output)  # https://superuser.com/a/380778
        output = output.replace(b'\r\n', b'\n')  # no idea why needed
        output = re.sub(rb'.*\r\x1b\[K', b'', output)  # the weird characters seem to mean "forget prev line"
        return self.substitute_commit_hashes(output.decode('utf-8'))

    def add_outputs_to_commands(self, command_string):
        commands = [
            line.lstrip('$').strip()
            for line in command_string.split('\n')
            if line.startswith('$')
        ]
        outputs = [self.run_command(command) for command in commands]
        return '\n'.join(
            f"$ {command}\n{output}"
            for command, output in zip(commands, outputs)
        )


with tempfile.TemporaryDirectory() as tempdir_string:
    tempdir = pathlib.Path(tempdir_string)
    (tempdir / 'fake_editor').write_text('''\
#!/bin/bash
echo "add better description to README" > "$1"
''')
    (tempdir / 'fake_editor').chmod(0o755)
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
        git config user.name "Your Name"
        git checkout -q -b main
        git add .
        git commit -q -m "Initial commit"
        git config receive.denyCurrentBranch ignore
        ''',
        shell=True,
        check=True,
        cwd=(tempdir / 'fake_github' / 'reponame'),
    )

    (tempdir / 'cloned' / 'reponame').mkdir(parents=True)
    runner = CommandRunner(tempdir)

    for filename in ['getting-started.md', 'committing.md']:
        print("Running commands from", filename)
        path = pathlib.Path(filename)
        content = path.read_text()
        old_parts = content.split('```')

        new_parts = []
        for part in old_parts:
            if part.startswith(('sh\n', 'diff\n')):  # ```sh or ```diff
                new_parts.append(part.split('\n')[0] + '\n' + runner.add_outputs_to_commands(part))
            else:
                new_parts.append(part)
                if 'Now open `README.md` in your favorite text editor' in part:
                    (runner.working_dir / 'README.md').write_text("""\
# reponame
This is a better description of this repository. Imagine you just wrote it
into your text editor.

More text here. Lorem ipsum blah blah blah.
""")

        path.write_text('```'.join(new_parts))
