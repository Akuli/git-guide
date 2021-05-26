import pathlib
import re


def get_markdown_filenames_from_readme():
    full_content = pathlib.Path('README.md').read_text()
    match = re.search(r'\nContents:\n((?:- \[.*\]\(.*\): .*\n)+)', full_content)
    assert match is not None
    return [line.split('(')[1].split(')')[0] for line in match.group(1).splitlines()]


def command_subber(match):
    commands = '\n'.join(re.findall(r'^\$ .*', match.group(0), flags=re.MULTILINE))
    return f'\n<%self:runcommands>\n{commands}\n</%self:runcommands>\n'


for filename in get_markdown_filenames_from_readme():
    markdown = pathlib.Path(filename).read_text()
    markdown = re.sub(r' `([^`\n]+)`', r' <code>\1</code>', markdown)
    markdown = re.sub(r'\n```diff\n((?:[^`].*\n|\n)+)```\n', command_subber, markdown)
    markdown = re.sub(r'^# (.*)', r'<h1>\1</h1>', markdown)
    markdown = re.sub(r'^## (.*)', r'<h2>\1</h2>', markdown, flags=re.MULTILINE)
    markdown = re.sub(r'^### (.*)', r'<h3>\1</h2>', markdown, flags=re.MULTILINE)
    markdown = re.sub(r'\n\n(?=[A-Z])', r'\n\n<p>', markdown, flags=re.MULTILINE)
    markdown = re.sub(r'\n\n(?=\.\.\.)', r'\n\n<p>', markdown, flags=re.MULTILINE)
    with open(f"mako-templates/{filename.split('.')[0]}.html", "w") as file:
        file.write('<%inherit file="base.html"/>\n')
        file.write('<%namespace file="base.html" import="runcommands"/>\n')
        file.write('\n')
        file.write(markdown)
