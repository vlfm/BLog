import BLog
import UIKit

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func logButtonTap(_ sender: UIButton) {
        if let text = textField.text {
            Log.debug(text)
            Log.error(text)
            Log.fatal(text)
            Log.info(text)
            Log.raw(text)
            Log.verbose(text)
            Log.warning(text)
        }
    }
    
    @IBAction private func exportButtonTap(_ sender: UIButton) {
        Log.export(fileName: "Log.txt") { url, error in
            if let error = error {
                print("Log export error: \(error)")
            }
            if let url = url {
                DispatchQueue.main.async {
                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    vc.completionWithItemsHandler = { _, _, _, _ in
                        
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}
