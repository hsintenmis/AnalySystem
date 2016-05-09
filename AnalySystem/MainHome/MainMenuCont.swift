//
// Static TabeleView, parent 的 ContainerView 轉入 
//

import UIKit

/**
 * 主選單項目列表頁面
 */
class MainMenuCont: UITableViewController {
    
    // @IBOutlet
    @IBOutlet var grpLabMenu: [UILabel]!
    
    // common property
    private var pubClass = PubClass()
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // 設定頁面顯示文字
        self.setPageLang()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        for labMenu in grpLabMenu {
            labMenu.text = pubClass.getLang(labMenu.restorationIdentifier)
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        let strIdent = segue.identifier
        
        if (strIdent == "MainMenuCont") {
            return
        }
        */
        
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}