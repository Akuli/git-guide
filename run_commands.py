import collections
import pathlib
import re
import subprocess
import sys
import tempfile


# Git output includes time stamps and commit hashes that are different every time this script runs
# Data taken from git-guide commits:  git log --format="FakeCommit('%T', '%ad'),"
FakeCommit = collections.namedtuple('FakeCommit', ['full_hash', 'timestamp'])
fake_commits = [
    FakeCommit('eea7704461d1d3ab18c07a9fd1ef8c8803553e52', 'Tue May 25 19:39:17 2021 +0300'),
    FakeCommit('9cfe4460b2709d4575d6df13cb83ee6e00e40a01', 'Mon May 24 21:04:05 2021 +0300'),
    FakeCommit('d21685edc8268b4369fe00a1b057e4b24a8d12db', 'Mon May 24 20:34:45 2021 +0300'),
    FakeCommit('cad28e22d712c3ee9a185dccbce3609a6d9faff7', 'Mon May 24 18:34:38 2021 +0300'),
    FakeCommit('fb5aad1f60a80d2037e7fe1298b094b1f059bb07', 'Mon May 24 00:29:07 2021 +0300'),
    FakeCommit('fb5aad1f60a80d2037e7fe1298b094b1f059bb07', 'Mon May 24 00:28:13 2021 +0300'),
    FakeCommit('647f6c6fb034ecff75a7699457b592d3240443ce', 'Mon May 24 00:27:30 2021 +0300'),
    FakeCommit('b753376396613661abeb4608feee2785e54343d5', 'Mon May 24 00:27:04 2021 +0300'),
    FakeCommit('d32545d929d9fb243359165fd37f291a8896b8c7', 'Mon May 24 00:22:49 2021 +0300'),
    FakeCommit('53f1321b8b0a339b07fd6e2e32816e0c92019416', 'Mon May 24 00:20:28 2021 +0300'),
    FakeCommit('1e3d7a8d32430eb138bee2a526c1d5676f3a4da3', 'Mon May 24 00:19:58 2021 +0300'),
    FakeCommit('fb56bf9f2d8a10e66256cab721a7a6817b3162a3', 'Mon May 24 00:17:33 2021 +0300'),
    FakeCommit('c8e61efa6a858153ff57fb923a330cecbdf5d927', 'Mon May 24 00:16:13 2021 +0300'),
    FakeCommit('6f4300485993179cb171662bf419240ac17d89d0', 'Mon May 24 00:14:56 2021 +0300'),
    FakeCommit('8f466b5f969287e1801fe8d057f3148398174a5d', 'Sun May 23 21:56:26 2021 +0300'),
    FakeCommit('a713ead26f8e9a609c3eb5e727f66db430574be7', 'Sun May 23 20:35:31 2021 +0300'),
    FakeCommit('4a5095bcb0e05894e7271cde6ea6b6b153916e7c', 'Sun May 23 20:17:20 2021 +0300'),
    FakeCommit('9900601fc325837bf3c3a40eaeffedc1e2ec5e85', 'Sun May 23 20:00:50 2021 +0300'),
    FakeCommit('9900601fc325837bf3c3a40eaeffedc1e2ec5e85', 'Sun May 23 18:32:49 2021 +0300'),
    FakeCommit('94265fe47a65daa152f9c8ffa66dab336c0161c6', 'Sun May 23 18:20:51 2021 +0300'),
    FakeCommit('78b197bfe895cd73d988853685ff5a308d61dab3', 'Sun May 23 16:06:58 2021 +0300'),
    FakeCommit('1f956800248ad1d577039a92f05beee9e05c1a0f', 'Sun May 23 15:34:50 2021 +0300'),
    FakeCommit('5bf1f4e2101b044e4032b23fe6940f3cd1c9f33f', 'Sun May 23 15:31:25 2021 +0300'),
    FakeCommit('c31289bd02f89d5b1b19040d419365a58edfa6d7', 'Sun May 23 15:24:51 2021 +0300'),
    FakeCommit('e008dfa2f1380a4f2d99b7a0ad3d4a10d75f5f06', 'Sun May 23 00:42:34 2021 +0300'),
]


class CommandRunner:

    def __init__(self, tempdir):
        self.working_dir = tempdir / 'working_dir'
        self.fake_github_dir = tempdir / 'fake_github' / 'reponame'
        self.git_config = {
            'core.pager': 'cat',
            'core.editor': 'true',
            # Ensure we get same error as with freshly installed git
            'user.email': '',
            'user.name': '',
        }
        self.fake_commits_by_hash = {}
        self.working_dir.mkdir()
        self.unused_fake_commits = fake_commits.copy()

    def get_fake_commit(self, commit_hash):
        # support short and long hashes
        commit_hash = commit_hash[:7]

        # If it is already a fake commit, return it unchanged
        for fake_commit in fake_commits:
            if fake_commit.full_hash.startswith(commit_hash):
                return fake_commit

        # Otherwise, it is an actual commit, and we map it to a fake commit
        if commit_hash not in self.fake_commits_by_hash:
            self.fake_commits_by_hash[commit_hash] = self.unused_fake_commits.pop()
        return self.fake_commits_by_hash[commit_hash]

    def handle_commit_hash_output(self, regex_match):
        commit_hash = regex_match.group(0)
        return self.get_fake_commit(commit_hash).full_hash[:len(commit_hash)]

    def handle_commit_hash_input(self, regex_match):
        [actual_hash] = [
            actual_hash
            for actual_hash, fake_commit in self.fake_commits_by_hash.items()
            if fake_commit.full_hash.startswith(regex_match.group(0))
        ]
        return actual_hash

    def handle_git_log_output(self, regex_match):
        full_hash, stuff_after_full_hash, author = regex_match.groups()
        fake_commit = self.get_fake_commit(full_hash)
        return (
            f"commit {fake_commit.full_hash}{stuff_after_full_hash}\n"
            f"Author: {author}\n"
            f"Date: {fake_commit.timestamp}\n"
        )

    # Git commit hashes are different every time this script runs. Maybe they
    # include some kind of UUID or system time, idk. But we want consistent output.
    def substitute_changing_info(self, git_output):
        git_output = re.sub(
            (
                # To replace time stamps with fake commits, we need to also
                # know commit hash, because two different commits can have the
                # same time stamp
                r'commit ([0-9a-f]{40})(.*)\n'
                r'Author: (.+ <.+>)\n'
                r'Date: .*\n'
            ),
            self.handle_git_log_output,
            git_output,
        )
        git_output = re.sub(
            r'\b([0-9a-f]{7}|[0-9a-f]{40})\b',
            self.handle_commit_hash_output,
            git_output,
        )
        return git_output

    def run_command(self, bash_command, old_output):
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
            return old_output   # pushing to same computer wouldn't look realistic

        if bash_command.startswith('cd '):
            self.working_dir /= bash_command[3:]
            return ''  # No output

        if bash_command.startswith('git push'):
            subprocess.run(
                ['bash', '-c', bash_command],
                cwd=self.working_dir,
                check=('fatal:' not in old_output),
            )
            return old_output   # pushing to same computer wouldn't look realistic

        # For example:  git config --global user.name "yourusername"
        bash_command = bash_command.replace('--global', '')

        # For commands that contain commit hashes
        bash_command = re.sub(r'\b[0-9a-f]{7}\b', self.handle_commit_hash_input, bash_command)

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

        output = response.stdout
        output = output.expandtabs(8)
        output = re.sub(rb"\x1b\[[0-9;]*m", b"", output)  # https://superuser.com/a/380778
        output = output.replace(b'\r\n', b'\n')  # no idea why needed
        output = re.sub(rb'.*\r\x1b\[K', b'', output)  # the weird characters seem to mean "forget prev line"
        return self.substitute_changing_info(output.decode('utf-8'))

    def add_outputs_to_commands(self, command_string):
        commands_and_outputs = []
        while command_string:
            match = re.match(r'\$ (.*)\n((([^$\n].*)?)\n)*', command_string)
            assert match is not None, command_string
            command = match.group(1)
            output = match.group(0).split('\n', maxsplit=1)[1].rstrip('\n') + '\n'
            commands_and_outputs.append((command, output))
            command_string = command_string[match.end():]

        return '\n'.join(
            f"$ {command}\n{self.run_command(command, old_output)}"
            for command, old_output in commands_and_outputs
        )

    def get_branch(self):
        git_status = subprocess.check_output(
            ['git', 'status'], cwd=self.working_dir
        ).decode('ascii')
        assert git_status.startswith('On branch ')
        return git_status.split('\n')[0].replace('On branch ', '', 1)

    def edit_file(self, instructions, new_content):
        append_match = re.fullmatch(r'Add to end of (.*) \(on branch (.*)\)', instructions)
        if append_match is not None:
            filename, branch = append_match.groups()
            assert branch == self.get_branch(), (instructions, self.get_branch())

            path = pathlib.Path(self.working_dir / append_match.group(1))
            with path.open("a") as file:
                file.write(new_content)
            return

        last_line_match = re.fullmatch(r'Last line of (.*) \(on branch (.*)\)', instructions)
        if last_line_match is not None:
            filename, branch = last_line_match.groups()
            assert branch == self.get_branch()
            path = pathlib.Path(self.working_dir / last_line_match.group(1))
            staying_content = ''.join(path.read_text().splitlines(True)[:-1])
            path.write_text(staying_content + new_content)
            return

        content_match = (
            re.fullmatch(r'Write this to (.*)', instructions)
            or re.fullmatch(r'Edit (.*) so that it looks like this', instructions)
        )
        if content_match is not None:
            pathlib.Path(self.working_dir / content_match.group(1)).write_text(new_content)
            return

        raise ValueError(f"bad instructions: {instructions}")


def get_markdown_filenames_from_readme():
    full_content = pathlib.Path('README.md').read_text()
    match = re.search(r'\nContents:\n((?:- \[.*\]\(.*\): .*\n)+)', full_content)
    assert match is not None
    return [line.split('(')[1].split(')')[0] for line in match.group(1).splitlines()]


with tempfile.TemporaryDirectory() as tempdir_string:
    tempdir = pathlib.Path(tempdir_string)
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

    (tempdir / 'cloned' / 'reponame').mkdir(parents=True)
    runner = CommandRunner(tempdir)

    for filename in get_markdown_filenames_from_readme():
        print("Running commands from", filename)
        path = pathlib.Path(filename)
        content = path.read_text()
        old_parts = content.split('```')

        new_parts = []
        for part in old_parts:
            if part.startswith('diff\n'):  # ```diff
                new_parts.append('diff\n' + runner.add_outputs_to_commands(part[5:]))
            else:
                new_parts.append(part)
                if part.startswith('python\n# '):  # python file
                    literally_python, instructions_line, content = part.split('\n', maxsplit=2)
                    runner.edit_file(instructions_line.lstrip('# '), content)
                # TODO: get rid of this hard-coding
                elif 'Now open `README.md` in your favorite text editor' in part:
                    (runner.working_dir / 'README.md').write_text("""\
# reponame
This is a better description of this repository. Imagine you just wrote it
into your text editor.

More text here. Lorem ipsum blah blah blah.
""")

        path.write_text('```'.join(new_parts))
