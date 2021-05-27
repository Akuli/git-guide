import pathlib
import shutil

from mako.lookup import TemplateLookup

from pagelist import pagelist


MAKO_TEMPLATES = pathlib.Path('mako-templates')
BUILD = pathlib.Path('build')

try:
    shutil.rmtree(BUILD)
except FileNotFoundError:
    pass
BUILD.mkdir()


lookup = TemplateLookup(directories=['./mako-templates'])

for filename in [filename for filename, *junk in pagelist] + ['index.html']:
    template = lookup.get_template(filename)
    print("Writing", BUILD / filename)
    (BUILD / filename).write_text(template.render(filename=filename), encoding='utf-8')
