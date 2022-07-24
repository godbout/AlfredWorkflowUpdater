import Foundation
import AlfredWorkflowUpdaterCore


guard CommandLine.arguments.count >= 3 else { exit(1) }

exit(Updater.main())
