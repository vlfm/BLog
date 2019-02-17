import BLog
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpCustomLogger()
        
//        do {
//            try Log.setUpDefault()
//        } catch {
//            print("Setup logger error: \(error)")
//        }
        
        return true
    }
}

extension AppDelegate {
    private func setUpCustomLogger() {
        guard let directoryUrl = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask).first else {
                print("Failed to get application support directory")
                return
        }
        
        let fileLogDirectoryUrl = directoryUrl.appendingPathComponent("Log")
        let fileLogConfiguration = FileLogConfiguration(directoryUrl: fileLogDirectoryUrl,
                                                        fileCount: 10,
                                                        fileSize: 500_000)
        
        let queue = DispatchQueue(label: "Logger")
        let logger = LogDispatcher(DispatchQueue(label: "Logger"))
        let consoleDestination = FormattedLogWriter(StandardLogEntryFormatter(.console),
                                                    ConsoleLogOutput())
        let fileDestination = FormattedLogWriter(StandardLogEntryFormatter(.file),
                                                 FileLogOutput(fileLogConfiguration))
        
        logger.add(consoleDestination)
        logger.add(fileDestination)
        
        let logExporter = LogExporter(queue, FileLogAssembler(fileLogConfiguration))
        
        Log.logger = logger
        Log.logExporter = logExporter
    }
}
