//
// VC 包含 ContainerView
//

import UIKit

/**
 * 主選單頁面
 */
class MainMenu: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var navyTitle: UINavigationItem!
    @IBOutlet weak var labBtmMsg0: UILabel!
    @IBOutlet weak var labBtmMsg1: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 傳入
    var dictAllData: Dictionary<String, AnyObject>!
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定頁面語系
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
        labBtmMsg0.text = String(format: pubClass.getLang("FMT_userprivmsg"), dictAllData["name"] as! String)
        
        var strPriv = ""
        let aryPriv = dictAllData["priv"] as! Array<String>
        
        for loopi in (0..<aryPriv.count) {
            strPriv += pubClass.getLang("countryname_" + aryPriv[loopi])
            if (loopi < (aryPriv.count - 1)) {
                strPriv += ","
            }
        }

        labBtmMsg1.text = strPriv
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "MainMenuCont") {
            return
        }
        
        return
    }
    
    /**
     * act, btn '登出'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}