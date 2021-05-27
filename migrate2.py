import pathlib
import re


for path in pathlib.Path('mako-templates').glob('*.html'):
    content = path.read_text()
    content = re.sub(r'\[(.+?)\]\((\S+?)\)', r'<a href="\2">\1</a>', content)
    content = re.sub(r'\*\*([^\*\n]+)\*\*', r'<strong>\1</strong>', content)
    content = re.sub(r'(?<=[ \n])(https://(\S+))', r'<a href="\1">\2</a>', content)
    content = re.sub(r'git clone <a href="(.+)">.*</a>', r'git clone \1', content)
    content = re.sub(r'/</a>', r'</a>', content)

    content = re.sub(
        r'\n```(\S+)\n# Write this to (.+)\n((?:.*\n)+?)```\n',
        r'\n<%self:code lang="\1" write="\2">\n\3</%self:code>\n',
        content,
    )
    content = re.sub(
        r'\n```(\S+)\n# Edit (.+) so that it looks like this\n((?:.*\n)+?)```\n',
        r'\n<%self:code lang="\1" write="\2">\n\3</%self:code>\n',
        content,
    )
    content = re.sub(
        r'\n```(\S+)\n# Add to end of (.+) \(on branch .*\)\n((?:.*\n)+?)```\n',
        r'\n<%self:code lang="\1" append="\2">\n\3</%self:code>\n',
        content,
    )
    content = re.sub(
        r'\n```(\S+)\n# Last line of (.+) \(on branch .*\)\n((?:.*\n)+?)```\n',
        r'\n<%self:code lang="\1" replacelastline="\2">\n\3</%self:code>\n',
        content,
    )
    path.write_text(content)
