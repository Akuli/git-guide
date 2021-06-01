<!DOCTYPE html>

<%!
    import re
    import subprocess
    import textwrap

    from ansi2html import Ansi2HTMLConverter
    from colorama import Fore, Style
    from pygments import highlight, lexers, formatters

    from build import create_runner

    runner = create_runner()   # Runs only once, same runner reused
    pygments_formatter = formatters.HtmlFormatter(cssclass="pygments", style='monokai')
    ansi_converter = Ansi2HTMLConverter()

    def run_git_commands(input_string):
        should_be_empty, *commands_and_outputs = re.split(
            r'^\$ ', textwrap.dedent(input_string), flags=re.MULTILINE
        )
        assert not should_be_empty.strip(), "missing $ at start of commands"

        parts = []
        for command_and_output in commands_and_outputs:
            command, hard_coded_output = command_and_output.split('\n', maxsplit=1)
            if hard_coded_output.strip():
                # Run, but discard actual output
                runner.run_command(command)
                output = hard_coded_output
            else:
                output = runner.run_command(command)
                assert output is not None, command

            parts.append(Style.BRIGHT + '$ ' + Fore.CYAN + command + Style.RESET_ALL)
            parts.append(output)

        return ansi_converter.convert('\n'.join(parts), full=False)
%>

<%
    context.runner = runner  # TODO: this is a hack
%>

<%def name="h2()">
    <%
        text = capture(caller.body).lstrip("\n")
        element_id = re.sub(r'[^a-z]', '-', text.lower())
    %>

    <h2 id="${element_id}">
        ${text}<a class="headerlink" href="#${element_id}" title="Link to this title">¶</a>
    </h2>
</%def>

<%def name="commit(git_ref, long=False)"><%
    result = subprocess.check_output(
        ['git', 'rev-parse', git_ref],
        cwd=runner.working_dir,
    ).decode('ascii').strip()
    return result if long else result[:7]
%></%def>

<%def name="runcommands()">
    <pre>${run_git_commands(capture(caller.body))}</pre>
</%def>

<%def name="code(lang='text', write=None, append=None, replacelastline=None, read=None)">
    <div class="code-container">
        <% code = capture(caller.body).lstrip("\n") %>

        % if write is not None:
            % if (runner.working_dir / write).exists():
                <span>Change the content of ${write} to this:</span>
            % else:
                <span>Create ${write} with this content:</span>
            % endif
            <% (runner.working_dir / write).write_text(code) %>
        % elif append is not None:
            <span>Add to end of ${append}:</span>
            <%
                with (runner.working_dir / append).open("a") as file:
                    file.write(code)
            %>
        % elif replacelastline is not None:
            <span>Replace last line of ${replacelastline} with this:</span>
            <%
                assert code.endswith("\n") and code.count("\n") == 1

                with (runner.working_dir / replacelastline).open("r") as file:
                    lines = file.readlines()
                lines[-1] = code
                with (runner.working_dir / replacelastline).open("w") as file:
                    file.writelines(lines)
            %>
        % elif read is not None:
            <%
                assert not code.strip()
                code = (runner.working_dir / read).read_text()
            %>
        % endif

        ${highlight(code, lexers.get_lexer_by_name(lang), pygments_formatter)}
    </div>
</%def>

<html>
    <head>
        <title>${title}</title>
        <style>${pygments_formatter.get_style_defs()}</style>
        ${ansi_converter.produce_headers()}
        <link rel="stylesheet" href="css/style.css">
    </head>
    <body>
        <main>
            <h1>${title}</h1>
            ${self.body()}
        </main>

        <hr />

        <footer>
            % if filename != 'index.html':
                <p>
                % if prev_filename is not None:
                    Previous: <a href="${prev_filename}">${prev_title}</a><br />
                % endif

                % if next_filename is not None:
                    Next: <a href="${next_filename}">${next_title}</a><br />
                % endif

                <a href="index.html">Back to front page</a>
            % endif

            <p>This guide is developed in <a href="https://github.com/Akuli/git-guide">this GitHub repo</a>.
            Please create an issue if you notice a problem.
        </footer>
    </body>
</html>
