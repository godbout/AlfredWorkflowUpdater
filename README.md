<h1 align="center">Alfred Workflow Updater</h1>

<p align="center">
    <a href="https://github.com/godbout/AlfredWorkflowUpdater/releases"><img src="https://img.shields.io/github/release/godbout/AlfredWorkflowUpdater.svg" alt="GitHub Release"></a>
    <a href="https://github.com/godbout/AlfredWorkflowUpdater/actions"><img src="https://img.shields.io/github/workflow/status/godbout/AlfredWorkflowUpdater/tests%20and%20coverage" alt="Build Status"></a>
    <a href="https://codecov.io/gh/godbout/AlfredWorkflowUpdater"><img src="https://img.shields.io/codecov/c/gh/godbout/AlfredWorkflowUpdater" alt="Code Coverage"></a>
</p>

___

# What is that

It's a Command Line Tool that you embed in your Workflow. That is it.
Then you call it from your Workflow and it does some magic.

# Why

Who wants to go check GitHub or a forum post manually to update your Workflow hmm?

# OK, how does it work

You call Alfred Workflow Updater with 2 parameters:
1. your GitHub repo, like: "[godbout/WooshyWindowToTheForeground](https://github.com/godbout/WooshyWindowToTheForeground)"
2. the check frequency you want, in minutes, like: "60"

Alfred Workflow Updater will check if there's a file called `last_checked.plist` in your Workflow cache folder, and when was the last time the check was made.
If the threshold is passed, Alfred Workflow Updater checks online if there's an update available for your Workflow, checking your current local Workflow version against the online latest version available on GitHub.
If a an update is found, Alfred Workflow Updater drops an `update_available.plist` file in your Workflow cache folder. This file contains your latest release info (version, file URL, page URL).

All you have to do is pick up that file and show the update whenever you want.
Add an [item variable](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/#variables) to your Alfred Result with the name "AlfredWorkflowUpdater_action" and the value "update".
BOOM. Done.

# Hmm, any screenshot?

Better, a video:

# Any concrete example?

Those Workflows are using the Alfred Workflow Updater:
* [Alfred Kat](https://github.com/godbout/AlfredKat)
* [Wooshy: Window to the Foreground!](https://github.com/godbout/WooshyWindowToTheForeground)
