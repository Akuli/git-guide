import atexit
import html
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

from mako.lookup import TemplateLookup


pagelist = [
    ("index.html", "Akuli's Git Guide", "Front page"),
    ("getting-started.html", "Getting started", "installing Git, making and cloning a repo"),
    ("committing.html", "Committing", "add, commit, push, status, diff, log, show"),
    ("branches.html", "Branches", "checkout, lola, merge"),
    ("pr.html", "Pull requests", ""),
]


class CommandRunner:

    def __init__(self, tempdir):
        self.working_dir = tempdir / 'working_dir'
        self.fake_github_dir = tempdir / 'fake_github' / 'reponame'
        self.fake_fork_source_dir = tempdir / 'fake_fork_source' / 'reponame'
        self._repo_config_commands = [
            'git config core.pager cat',
            'git config core.editor true',  # Don't change commit message (for merge commits)
            'git config color.ui always',
            # Ensure we get same error as with freshly installed git
            'git config user.email ""',
            'git config user.name ""',
        ]
        self.working_dir.mkdir()
        self.fake_time = 1622133500  # seconds since epoch

    def run_command(self, command_string):
        print("  ", command_string)

        # Make sure commit timestamps differ. Otherwise the output order of
        # 'git log --oneline --graph --all' can vary randomly.
        #
        # Using a prime number helps make the commit times seemingly random.
        self.fake_time += 7

        if command_string == 'git clone https://github.com/username/reponame':
            subprocess.run(
                ['git', 'clone', '-q', str(self.fake_github_dir), str(self.working_dir / 'reponame')],
                check=True,
            )
            for command in self._repo_config_commands:
                subprocess.run(command, cwd=(self.working_dir / 'reponame'), check=True, shell=True)
            return None  # not used

        if command_string == 'git pull https://github.com/where_you_forked_it_from/reponame':
            subprocess.run(
                ['git', 'pull', str(self.fake_fork_source_dir)],
                cwd=self.working_dir,
                check=True,
            )
            return None   # not used

        if command_string.startswith('cd '):
            self.working_dir /= command_string[3:]
            return ''  # No output

        if command_string.startswith("git config --global "):
            command_string = command_string.replace('--global', '', 1)
            self._repo_config_commands.append(command_string)

        # Many programs display their output differently when they think the
        # output is going to a terminal. For this guide, we generally want
        # programs to think so. For example:
        #  - 'ls' should show file names separated by two spaces, not one file per line
        #  - 'git log --all --pretty --oneline' should show * on the left side of
        #    commit hashes, just like it does on terminal
        if sys.platform == 'win32':
            # Just run it in subprocess, supporting powershell syntax.
            # Output of 'git log' command above won't look right, but most things work.
            actual_command = ['powershell', command_string]
        else:
            # The pty module creates pseudo-TTYs, which are essentially fake
            # terminals. But for some reason, the output still goes to the real
            # terminal, so I have to do it in a subprocess and capture its
            # output.
            args = ['bash', '-c', command_string]
            actual_command = [sys.executable, '-c', f'import pty; pty.spawn({str(args)})']

        return (
            subprocess.run(
                actual_command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                cwd=self.working_dir,
                env={
                    **os.environ,
                    'GIT_AUTHOR_DATE': f'{self.fake_time} +0000',
                    'GIT_COMMITTER_DATE': f'{self.fake_time} +0000',
                },
            )
            .stdout
            .decode('utf-8')
            .expandtabs(8)
            .replace('\r\n', '\n')
            .replace(str(self.fake_github_dir), 'https://github.com/username/reponame')
        )


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

    commands = [
        ['git', 'init', '-q'],
        ['git', 'config', 'user.email', 'you@example.com'],
        ['git', 'config', 'user.name', 'yourusername'],
        ['git', 'config', 'receive.denyCurrentBranch', 'ignore'],
        ['git', 'checkout', '-q', '-b', 'main'],
        ['git', 'add', '.'],
        ['git', 'commit', '-q', '-m', 'Initial commit'],
    ]
    for command in commands:
        subprocess.run(command, check=True, cwd=(tempdir / 'fake_github' / 'reponame'))
    return CommandRunner(tempdir)


def _handle_code(match):
    return '<code>' + html.escape(match.group(0).strip('`'), quote=False) + '</code>'


def build():
    try:
        shutil.rmtree("build")
    except FileNotFoundError:
        pass
    os.mkdir("build")

    shutil.copytree("css", "build/css")
    shutil.copytree("images", "build/images")

    lookup = TemplateLookup(strict_undefined=True)
    for path in pathlib.Path("mako-templates").glob("*.mako"):
        print("Preparing", path)
        html_string = re.sub(r'`(.+?)`', _handle_code, path.read_text())
        lookup.put_string(path.stem + '.html', html_string)

    for index, page in enumerate(pagelist):
        prev_page = pagelist[index-1] if index >= 2 else (None, None, None)
        next_page = pagelist[index+1] if 1 <= index < len(pagelist)-1 else (None, None, None)

        kwargs = {}
        kwargs['filename'], kwargs['title'], kwargs['desc'] = page
        kwargs['prev_filename'], kwargs['prev_title'], kwargs['prev_desc'] = prev_page
        kwargs['next_filename'], kwargs['next_title'], kwargs['next_desc'] = next_page

        template = lookup.get_template(kwargs['filename'])
        path = pathlib.Path("build") / kwargs['filename']
        print("Writing", path)
        path.write_text(template.render(**kwargs), encoding='utf-8')


if __name__ == '__main__':
    build()
