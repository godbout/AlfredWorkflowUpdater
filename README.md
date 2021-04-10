<h1 align="center">Alfred Workflow Updater</h1>

<p align="center">
    <a href="https://github.com/godbout/AlfredWorkflowUpdater/releases"><img src="https://img.shields.io/github/release/godbout/AlfredWorkflowUpdater.svg" alt="GitHub Release"></a>
    <a href="https://github.com/godbout/AlfredWorkflowUpdater/actions"><img src="https://img.shields.io/github/workflow/status/godbout/AlfredWorkflowUpdater/tests%20and%20coverage" alt="Build Status"></a>
    <a href="https://app.codacy.com/gh/godbout/AlfredWorkflowUpdater"><img src="https://img.shields.io/codacy/grade/653415cfb541446f82e2f5dd84f56f16" alt="Quality Score"></a>
    <a href="https://codecov.io/gh/godbout/AlfredWorkflowUpdater"><img src="https://img.shields.io/codecov/c/gh/godbout/AlfredWorkflowUpdater" alt="Code Coverage"></a>
</p>

___

# WOT IS THAT M8

it's a library in Swift for you developers to easily add a way for your users to update your Workflow. i did that because Alfred Workflows deserve love with a capital l. (yes, both ls are minuscule.)

currently it only works with GitHub. the main reason for this is

# HOW TO INSTALL

usual install through SPM. no idea for Carthage or CocoaPod. if you don't know how to use SPM please come back later.

# HOW DOES IT WORK

## check if an update for your Workflow is available

```swift
import AlfredWorkflowUpdater

if let release = Updater.checkUpdater(for: "godbout/AlfredKat") {
    print("\(release.version) available. download at \(release.file). release page at \(release.page)")
}
```

## download and open the update

```swift
import AlfredWorkflowUpdater

Updater.update(with: releaseFileURL)
```

more probably than not you would have passed the `releaseFileURL` as a [Variable](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/#variables) after getting it back from `Updater.checkUpdater`.

## notify user of imminent download approach

currently AlfredWorkflowUpdater is dumbly built so it will block your script while the download is happening. as your script may send a notification only when it ends and returns results to Alfred, there might be a delay during which the user doesn't know what's happening. so the library provides a method to send a notification before the stupid blocking update.

```swift
import AlfredWorkflowUpdater

Updater.notify(title: "Alfred Kat", message: "downloading your shit update...")
```

unfortunately currently the notification is ugly because its icon is not customizable because of macOS but also more because i'm lazy.

**IMAGE OF SHIT NOTIFICATION**

## open stuff

there's another method that is supposed to be there in case you want to give the option to the user to open the release page but you can use it to open anything else, like a Pandora's box. 

```swift
Updater.open(page: releasePageURL)
```

# THE FUTURE

* background download
* better notification, although might get rid of it completely if can show the download progress as an item (with ScriptFilter rerun) 
