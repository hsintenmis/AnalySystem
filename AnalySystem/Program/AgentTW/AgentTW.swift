//
// TableView, SearchView
//

import UIKit

/**
 * 台灣總裁列表與搜尋
 */
class AgentTW: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var schBar: UISearchBar!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableDataOrg: Array<Dictionary<String, AnyObject>> = []
    
    // TableView, SearchBar 相關
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []  // 搜尋用
    private var currIndexPath: NSIndexPath? = nil
    private var searchActive : Bool = false
    
    // 其他參數
    private var aryDegree: Array<String>!
    private var bolReload = true // 頁面是否需要 http reload
    
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
        if (!bolReload) {
            return
        }
        bolReload = false
        
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
        aryDegree = dictAllData["level"] as! Array<String>
        aryTableDataOrg = dictAllData["data"] as! Array<Dictionary<String, AnyObject>>
        aryTableData = aryTableDataOrg
        
        tableList.reloadData()
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "topagentdata"
        mParam["act"] = "topagentdata_getdata"
        mParam["strCurrCountry"] = "TW"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離, 'err_searchmax', 'err_checknodata'
            if (dictRS["result"] as! Bool != true) {
                
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg)
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
        
        // 產生 Item data, 設定 cell field 需要的　value
        var dictItem = aryTableData[indexPath.row]
 
        dictItem["no"] = String(indexPath.row + 1)
        dictItem["degree_name"] = aryDegree[Int(dictItem["level"] as! String)!]
        
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellAgentTW", forIndexPath: indexPath) as! AgentTWCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
    /**
     * #mark: TableView VC delegate, table view Item 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let dictItem = aryTableData[indexPath.row]
        self.performSegueWithIdentifier("AgentTWDetail", sender: dictItem)

        return
    }
    
    /** mark: SearchBar delegate Start */
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    /** mark: SearchBar delegate End */
    
    /**
     * mark: SearchBar delegate
     * 搜尋字元改變時
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (aryTableDataOrg.count < 1) {
            searchActive = false;
            return
        }
        
        // 沒有輸入字元
        if (searchText.isEmpty) {
            searchActive = false;
            searchBar.resignFirstResponder()
            aryTableData = aryTableDataOrg
            self.tableList.reloadData()
            
            return
        }
        
        // 比對字元
        aryTableData = aryTableDataOrg.filter({ (dictItem) -> Bool in
            let arySechField = ["id", "description", "m_phone"]
            for strField in arySechField {
                if let strVal = dictItem[strField] as? String {
                    let tmp: NSString = strVal
                    let mRange = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    
                    if (mRange.location != NSNotFound) {
                        return true
                    }
                }
            }
            
            return false
        })
        
        if(aryTableData.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableList.reloadData()
    }

    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "AgentTWDetail") {
            let mVC = segue.destinationViewController as! AgentTWDetail
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            mVC.aryDegree = aryDegree
            
            return
        }
        
        return
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