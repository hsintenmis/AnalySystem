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
    
    /**
     * act, button group, 即時業績/歷史業績
     * 跳轉 storyboard 方式
     */
    @IBAction func actBtnGrpMenu(sender: UIButton) {
        let strIdentName = sender.restorationIdentifier
        var mVC = UIViewController()
        
        // 跳轉即時業績查詢
        if (strIdentName == "btnMenuBranchSale") {
            let storyboard = UIStoryboard(name: "BranchSale", bundle: nil)
            mVC = storyboard.instantiateViewControllerWithIdentifier("BranchSale") as! BranchSale
        }
        
        else if (strIdentName == "btnMenuHistory") {
            let storyboard = UIStoryboard(name: "HistorySale", bundle: nil)
            mVC = storyboard.instantiateViewControllerWithIdentifier("HistorySale") as! HistorySale
        }

        if (!mVC.isEqual(nil)) {
            mVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(mVC, animated: true, completion: nil)
            return
        }
        
        return
    }
    
    /**
     * act, button group, TW 權限
     */
    @IBAction func actGrpBtnTW(sender: UIButton) {
        // 檢查'TW'權限
        let aryPriv = pubClass.getAppDelgVal("V_PRIV") as! Array<String>
        var bolRS = false
        
        for strPriv in aryPriv {
            if (strPriv == "TW") {
                bolRS = true
                break;
            }
        }
        
        if (!bolRS) {
            pubClass.popIsee(self, Msg: pubClass.getLang("privlimitmsg"))
            return
        }
        
        // 跳轉對應 class
        let strIdentName = sender.restorationIdentifier
        
        if (strIdentName == "btnMenuLiability") {
            self.performSegueWithIdentifier("Liability", sender: nil)
            
            return
        }
        
        if (strIdentName == "btnMenuAgentTW") {
            self.performSegueWithIdentifier("AgentTW", sender: nil)
            
            return
        }
        
        return
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}