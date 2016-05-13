//
// TableView
//

import UIKit

/**
 * 直銷商搜尋 與 最近一年該直銷商積分顯示
 */
class SearchAgent: UIViewController, PickerCountryDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var edName: UITextField!
    @IBOutlet weak var edStat: UITextField!
    @IBOutlet weak var edAddr: UITextField!
    @IBOutlet weak var labNums: UILabel!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    private var aryPriv: Array<String>!  // user 國別權限
    private var currCountryCode = ""
    private var currEdField: UITextField?
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // field 設定
        let btnFroup = [btnCountry, btnClear, btnSearch]
        for btnTmp in btnFroup {
            btnTmp.layer.cornerRadius = 5.0
        }
        
        // TableCell 自動調整高度
        tableList.estimatedRowHeight = 120.0
        tableList.rowHeight = UITableViewAutomaticDimension
        
        // 設定 user 國別權限 array
        aryPriv = pubClass.getAppDelgVal("V_PRIV") as! Array<String>
        currCountryCode = aryPriv[0]
        
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
        btnCountry.setTitle(pubClass.getLang("countryname_" + currCountryCode), forState: UIControlState.Normal)
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        aryTableData = dictAllData["data"] as! Array<Dictionary<String, AnyObject>>
        labNums.text = String(aryTableData.count)
        
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
        mParam["page"] = "searchagent"
        mParam["act"] = "searchagent_getdata"
        mParam["country"] = currCountryCode
        
        // 搜尋參數設定, , id, addr, state
        if (edName.text?.characters.count > 0) {
            mParam["id"] = edName.text
        }
        
        if (edAddr.text?.characters.count > 0) {
            mParam["addr"] = edAddr.text
        }
        
        if (currCountryCode == "US" && edStat.text?.characters.count > 0) {
            mParam["state"] = edStat.text
        }
        
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
        
        let strDegree = dictItem["degree"] as! String
        let strLevel = dictItem["level"] as! String
        dictItem["degree_name"] =  strDegree + " " + strLevel
        
        dictItem["m_tel"] = ""
        if let strTmp = dictItem["tel"] as? String {
            dictItem["m_tel"] = strTmp
        }
        
        if let strTmp = dictItem["m_phone"] as? String {
            if ((dictItem["m_tel"] as! String).characters.count > 0) {
                dictItem["m_tel"] = dictItem["m_tel"] as! String + ", "
            }
            
            dictItem["m_tel"] = dictItem["m_tel"] as! String + strTmp
        }
        
        
        
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSearchAgent", forIndexPath: indexPath) as! SearchAgentCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
    /**
     * #mark: 選擇國別 PickerCountryDelegate Delegate
     */
    func doneSelect(strCountry: String) {
        currCountryCode = strCountry
        btnCountry.setTitle(pubClass.getLang("countryname_" + strCountry), forState: UIControlState.Normal)
    }
    
    /**
     * #mark: UITextFieldDelegate, 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    /**
     * #mark: UITextFieldDelegate, 虛擬鍵盤: 開始輸入資料
     */
    func textFieldDidBeginEditing(textField: UITextField!) {
        currEdField = textField
    }
    
    /**
     * act, btn '國別'
     */
    @IBAction func actCountry(sender: UIButton) {
        // 跳轉國別選擇 VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mVC = storyboard.instantiateViewControllerWithIdentifier("PickerCountry") as! PickerCountry
        
        mVC.aryCountry = aryPriv
        mVC.strSelCountry = currCountryCode
        mVC.delegate = self
        
        self.presentViewController(mVC, animated: true, completion: nil)
    }
    
    /**
     * act, btn '清除'
     */
    @IBAction func actClear(sender: UIButton) {
        // 虛擬鍵盤關閉
        if (currEdField != nil) {
             currEdField!.resignFirstResponder()
        }
        
        edName.text = ""
        edStat.text = ""
        edAddr.text = ""
    }
    
    /**
     * act, btn '搜尋'
     */
    @IBAction func actSearch(sender: UIButton) {
        // 虛擬鍵盤關閉
        if (currEdField != nil) {
            currEdField!.resignFirstResponder()
        }
        
        // HTTP 重新連線取得資料
        reConnHTTP()
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