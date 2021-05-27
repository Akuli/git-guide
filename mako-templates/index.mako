<%inherit file="base.html"/>
<%namespace file="base.html" import="runcommands"/>

<p>This is my attempt at writing a practical guide to using Git with GitHub.
Ideally, the official Git documentation would be so good that this isn't necessary, but it sucks.
The goal for this guide is to not suck.

<p>Contents:

<ul>
    <% import build %>
    % for filename, title, description in build.pagelist:
        % if filename != "index.html":
            <li><a href="${filename}">${title}</a>: ${description}</li>
        % endif
    % endfor
</ul>
