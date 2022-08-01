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

# Features

* checks for updates on GitHub in the background
* only checks when necessary (frequency checks)
* opens your GitHub release page if you want
* downloads your latest release, moves it to the Users' download folder, opens the workflow
* notifications of your download come from your Workflow, so it's non-blocking and uses your icon ✌🏼️

# OK, how does it work

Alfred Workflow Updater writes a file called `last_checked.plist` in your Workflow cache folder that holds information about the last online check.
When the threshold you specified as a argument (see [API](#in-your-workflow-script) is passed, Alfred Workflow Updater checks online if there's an update available for your Workflow, comparing your current local Workflow version against the online latest version available on GitHub.
If a an update is found, Alfred Workflow Updater drops an `update_available.plist` file in your Workflow cache folder. This file contains your latest release info (version, file URL, page URL).

All you have to do is pick up that file and show the update whenever and however you want in your own Alfred Workflow.

# Hmm, any screenshot?

Better, a video:

https://user-images.githubusercontent.com/121373/180831445-2a6f61bc-4cd9-4277-9f68-8ce08fe83e04.mp4

# API

## in your Workflow Script

Call the Alfred Workflow Updater tool with 2 parameters:
1. your GitHub repo, like: "[godbout/WooshyWindowToTheForeground](https://github.com/godbout/WooshyWindowToTheForeground)"
2. the frequency threshold in minutes, like "60"

## in your Alfred Results

You can:
1. generate an update of your Workflow by adding an [item variable](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/#variables) to your Alfred Result with the name `AlfredWorkflowUpdater_action` and the value `update`
2. open your Workflow's GitHub release page by adding an [item variable](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/#variables) to your Alfred Result with the name `AlfredWorkflowUpdater_action` and the value `open`

You do not need to pass any other variables with those Alfred Results. The Alfred Workflow Updater will grab the necessary info from your Workflow's cache folder instead.

# Any concrete example?

The following Workflows are using the Alfred Workflow Updater. Best is to download one of them, open it, and check how it's made (it's simple):
* [Alfred Kat](https://github.com/godbout/AlfredKat)
* [Wooshy: Window to the Foreground!](https://github.com/godbout/WooshyWindowToTheForeground)
