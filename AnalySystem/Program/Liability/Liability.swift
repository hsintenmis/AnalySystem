//
// TableView
//

import UIKit

/**
 * 直銷商責任額列表, 顯示該季每月業績額
 */
class Liability: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labCountry: UILabel!

    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<String> = []
    
    // 其他參數
    private var arySeason: Array<String>!  // YYMM array
    private var aryLiab: Array<Int>!  // 責任額，依等級劃分, 2~4
    private var aryLevel: Array<String>!  // Level 對應名稱
    
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
        // HTTP 重新連線取得資料
        reConnHTTP()
    }
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        let dictTmp = dictAllData["data"] as! Dictionary<String, AnyObject>
        let dictTWData = dictTmp["TW"] as! Dictionary<String, AnyObject>
        
        // Level 對應名稱, 目前為台灣等級名稱
        //arySeason = dictAllData["level"] as! Array<String>
        print(dictAllData["level"])
        
        // 本季 YYMM 
        arySeason = dictTWData["level"] as! Array<String>
        
        // 責任額，依等級劃分, 2~4
        print(dictTWData["liability"]!)
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "liability"
        mParam["act"] = "liability_getdata"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            self.dictAllData = dictData
            self.chkHaveData()
        })
    }
    
    
    /**
     * #mark: UITableView Delegate, Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (aryTableData.count > 0) ? 1 : 0
    }
    
    /**
     * #mark: UITableView Delegate, section 內的 row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate, UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        return UITableViewCell()
        
        // 產生 Item data
        /*
        let strOffice = aryTableData[indexPath.row]
        let dictBranchdata = dictAllData[strBranch]![isToday] as! Dictionary<String, AnyObject>
        var dictItem = dictBranchdata[strOffice] as! Dictionary<String, AnyObject>
        
        dictItem["branch"] = strBranch
        dictItem["office"] = strOffice
        dictItem["isUnit"] = isPriceUnit
        
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellBranchSale", forIndexPath: indexPath) as! BranchSaleCell
        
        mCell.initView(dictItem)
        
        return mCell
        */
    }
    
    /**
     * act, btn '主選單'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}