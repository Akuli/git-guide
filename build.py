import pathlib
import shutil

from mako.lookup import TemplateLookup


MAKO_TEMPLATES = pathlib.Path('mako-templates')
BUILD = pathlib.Path('build')

try:
    shutil.rmtree(BUILD)
except FileNotFoundError:
    pass
BUILD.mkdir()


mylookup = TemplateLookup(directories=['./mako-templates'])

for source_path in MAKO_TEMPLATES.glob("*.html"):
    if source_path.name == 'base.html':
        continue

    template = mylookup.get_template(source_path.name)
    target_path = BUILD / source_path.name
    print("Writing", target_path)
    target_path.write_text(template.render(), encoding='utf-8')
