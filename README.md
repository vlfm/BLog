# BLog

BLog is a logger written in Swift.

### Write log messages using Log

You can use `Log` type to write messages to the log. There are set of static methods, one for each log level, that takes a `String`:

```swift
Log.debug("Debug message")
Log.error("Error message")
Log.fatal("Fatal message")
Log.info("Info message")
Log.raw("Raw message")
Log.verbose("Verbose message")
Log.warning("Warning message")
```

Each method also can take a `sync` parameter indicating if writing to the log should be performed in the caller's thread.
By default, `sync` is false.
```swift
Log.fatal("Fatal message", sync: true)
```

### Write log messages using Logger

If you don't want to use static methods of `Log`, or you need an instance (or several instances) of a logger object that you can pass around, you can use `Logger` type instead.

`Logger` is the core interface for writing messages to the log and it looks like this:
```swift
public protocol Logger {
    func log(_ message: LogEntry.Message, _ source: LogEntry.Source?, sync: Bool)
}
```

`LogEntry.Message` describes a log message and `LogEntry.Source` contains information about the place where log message appears (source file, function, and line number).

There is an extension of `Logger` that provides more convenient api, so that `Logger` can be used like this:
```swift
let logger: Logger = //
logger.log(.debug, "Debug message")
logger.log(.fatal, "Fatal message", sync: true)
```

### Where log messages are written?

Concrete type that implements `Logger` interface is `LogDispatcher`.
`LogDispatcher` takes log messages and forwards them to one or more `LogDestination`s.
You can add multiple `LogDestination`s to one `LogDispatcher`.

Simplified interface of `LogDispatcher` looks like this:
```swift
public final class LogDispatcher {
    public init(_ queue: DispatchQueue, _ clock: @escaping Clock = default)
    public func add(_ destination: LogDestination, _ filter: @escaping Filter = default)
}
```

And `LogDestination` is a protocol that looks like this:
```swift
public protocol LogDestination {
    func receive(_ entry: LogEntry) throws
}
```

There are two types of log destinations that the library provides: console and file log destinations.

### About log message formatting

All information that are passed to the logger should be formatted into a string before it could be written to an output (console or file).
`LogEntryFormatter` has the responsibility to format a `LogEntry` into a `String`.
```swift
public protocol LogEntryFormatter {
    func format(_ entry: LogEntry) -> String
}
```

There is concrete `LogEntryFormatter` implementation called `StandardLogEntryFormatter`. It takes a configuration object that you can use to modify some parameters used for formatting. There are predefined configurations for console and file log output.
This is how formatted log messages look like:
```
// Console
23:35:31.074 | ◼️ | Hello, Log!
23:35:31.099 | ❌ | Hello, Log!
23:35:31.099 | 💀 | Hello, Log!
23:35:31.099 | 🔷 | Hello, Log!
Hello, Log!
23:35:31.099 | ◻️ | Hello, Log!
23:35:31.099 | ⚠️ | Hello, Log!

// File
05/02/2019 23:35:31.074 | Debug | Hello, Log!
05/02/2019 23:35:31.099 | Error | Hello, Log!
05/02/2019 23:35:31.099 | Fatal | Hello, Log!
05/02/2019 23:35:31.099 | Info | Hello, Log!
Hello, Log!
05/02/2019 23:35:31.099 | Verbose | Hello, Log!
05/02/2019 23:35:31.099 | Warning | Hello, Log!
```

Note that messages with `raw` log level are not formatted and are written as is.

By default, `LogEntry.Source` formatting is disabled. You can enable it with `shouldIncludeSource` property of `StandardLogEntryFormatter.Configuration`. With this, log messages will include `#file`, `#function`, and `#line` information.
```
23:50:43.620 | ◼️ | ViewController.swift.logButtonTap:13 | Hello, Log!
23:50:43.627 | ❌ | ViewController.swift.logButtonTap:14 | Hello, Log!
23:50:43.627 | 💀 | ViewController.swift.logButtonTap:15 | Hello, Log!
23:50:43.627 | 🔷 | ViewController.swift.logButtonTap:16 | Hello, Log!
Hello, Log!
23:50:43.627 | ◻️ | ViewController.swift.logButtonTap:18 | Hello, Log!
23:50:43.628 | ⚠️ | ViewController.swift.logButtonTap:19 | Hello, Log!
```

### Console Logger

```swift
let logger: LogDispatcher = //
let consoleDestination = FormattedLogWriter(StandardLogEntryFormatter(.console),
                                            ConsoleLogOutput())
logger.add(consoleDestination)
```

### File Logger

To create a file logger (file log destination), you first need to create a log file configuration. The configuration specifies three things:
  * A directory url where log files will be located.
  * How many files are used in log rotation.
  * Max size of single individual file used in rotation.
  
```swift
guard let directoryUrl = FileManager.default.urls(
    for: .applicationSupportDirectory,
    in: .userDomainMask).first else {
        throw TextError("Failed to get application support directory")
}
        
let fileLogDirectoryUrl = directoryUrl.appendingPathComponent("Log")
let fileLogConfiguration = FileLogConfiguration(directoryUrl: fileLogDirectoryUrl,
                                                fileCount: 10,
                                                fileSize: 500_000)
// file log will have 10 files, 500kb each, 5mb overall
```

Next, you can create file log destination and add it to the logger.
```swift
let fileDestination = FormattedLogWriter(StandardLogEntryFormatter(.file),
                                         FileLogOutput(fileLogConfiguration))
        
let logger: LogDispatcher = //
logger.add(consoleDestination)
logger.add(fileDestination)
```

### File Log Exporting

You can export log using `LogExporter`. Log is exported into separate file and `URL` is provided in completion handler. There is also convenient method that provides contents of exported log file as `Data`.
```swift
public final class LogExporter {
    public func export(fileName: String, completionHandler: @escaping (URL?, Error?) -> Void)
    public func export(completionHandler: @escaping (Data?, Error?) -> Void)
}
```

To create `LogExporter` for exporting file log, pass it the same `FileLogConfiguration` used for creating file logger.
```swift
let fileLogConfiguration : FileLogConfiguration = ///
let logExporter = LogExporter(queue, FileLogAssembler(fileLogConfiguration))
```

Just like with writing log messages, `Log` also provides methods for log exporting.
```swift
Log.export(fileName: "Log.txt") { url, error in
  //
}
```

### LoggerFactory

`LoggerFactory` creates a pair of `Logger` and `LogExporter` with console and file destinations.
```swift
let queue = DispatchQueue(label: "Logger")
let fileLogConfiguration : FileLogConfiguration = ///
let (logger, logExporter) = LoggerFactory.make(queue, fileLogConfiguration)
```

### Default Setup

Default log configuration with console and file destinations is supported by `Log` with `setUpDefault` static method.
```swift
do {
  try Log.setUpDefault()
} catch {
  print("Setup logger error: \(error)")
}
Log.info("Hello, Log!")
```

### Manual Setup

Note that if you create your own `Logger` and/or `LogExporter` and want to use them through `Log` interface, you need to assign them to appropriate properties:
```swift
let logger = //
let logExporter = //
Log.logger = logger
Log.logExporter = logExporter
Log.info("Hello, Log!")
```
