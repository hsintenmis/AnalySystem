//
// VC 包含 ContainerView
//

import UIKit

/**
 * 歷史業績主頁面
 */
class HistorySale: UIViewController, PickerCountryDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var btnYYMM: UIButton!
    @IBOutlet weak var btnTot: UIButton!
    @IBOutlet weak var labGrayMsg: UILabel!
    @IBOutlet weak var labCurrenctMsg: UILabel!
    
    @IBOutlet weak var labTotTitle: UILabel!
    @IBOutlet weak var labYYMMpreiod: UILabel!
    @IBOutlet weak var labNameTot: UILabel!
    
    @IBOutlet weak var edCountry0: UITextField!
    @IBOutlet weak var edCountry1: UITextField!
    @IBOutlet weak var edCountry2: UITextField!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<AnyObject> = []
    
    // 其他參數
    private var aryPriv: Array<String>!
    private var aryIndexYM = [0, 23]  // YYMM 起始 position
    private var aryCurrCountry: Array<String> = []  // 目前選擇的國別
    private var mPickerCountry: PickerCountry!
    private var arySelCountryCode: Array<String> = []
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Picker 設定, 國別選擇
        let aryEdCountry = [edCountry0, edCountry1, edCountry2]
        
        aryPriv = pubClass.getAppDelgVal("V_PRIV") as? Array<String>
        for loopi in (0..<3) {
            if let strCountry: String = aryPriv[loopi] {
                aryCurrCountry.append(strCountry)
                aryEdCountry[loopi].text = pubClass.getLang("countryname_" + strCountry)
                arySelCountryCode.append(strCountry)
            } else {
                aryEdCountry[loopi].text = "--"
                aryEdCountry[loopi].enabled = false
            }
        }

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
     * 根據 YYMM 區間，重新產生 Table data source
     */
    private func chkHaveData() {
        var dictData: Dictionary<String, AnyObject> = [:]
        var dictTot: Dictionary<String, Dictionary<String, Float>> = [:]
        
        // 根據 YYMM 起始 position, 產生 user 權限國別的資料
        for strPriv in aryPriv {
            var aryAll: Array<Dictionary<String, AnyObject>> = []
            if let aryTmp = dictAllData[strPriv] as? Array<Dictionary<String, AnyObject>> {
                aryAll = aryTmp
            }
            
            var aryData: Array<Dictionary<String, AnyObject>> = []
            var fltNT: Float = 0.0
            var fltOrg: Float = 0.0
            let nums = aryAll.count
            
            for loopi in (aryIndexYM[0]..<aryIndexYM[1]) {
                var dictData: Dictionary<String, AnyObject> = [:]
                
                if (nums > 0 && nums > loopi) {
                    dictData = aryAll[loopi]
                    fltNT += Float(dictData["MM_NT"] as! String)!
                    fltOrg += Float(dictData["MM_ORG"] as! String)!
                }
                
                aryData.append(dictData)
            }
            
            dictData[strPriv] = aryData
            dictTot[strPriv] = ["NT":fltNT, "ORG":fltOrg]
        }
 
        // 產生 Table data source, Table reload
        aryTableData = []
        aryTableData.append(dictData)
        aryTableData.append(dictTot)
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
        mParam["page"] = "historysale"
        mParam["act"] = "historysale_getdata"
        
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
        return (aryTableData.count > 0) ? 2 : 0
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
        
        // 各國資料列表
        if (indexPath.section == 0) {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellHistorySale", forIndexPath: indexPath) as! HistorySaleCell
            let dictCountryData = aryTableData[0]
            let nums = dictCountryData.count
            var dictItem: Dictionary<String, String> = [:]
            
            for loopi in (0..<3) {
                if (nums >= loopi) {
                    dictItem["NT_" + String(loopi)] = ""
                } else {
                    
                }
            }
            
            
            mCell.initView(dictItem)
            
            return mCell
        }
        
        

    }
    
    /**
     * #mark: UIText 'Field' Delegate
     * 虛擬鍵盤: 點取 edField 開始輸入字元
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        let strCountry = arySelCountryCode[textField.tag]
        mPickerCountry = PickerCountry(withUIField: textField, aryCountry: aryPriv, defCountry: strCountry, strTitle: pubClass.getLang("selcountry"))
        mPickerCountry.delegate = self
    }
    
    /**
     * #mark: PickerCountryDelegate Delegate
     */
    func doneSelect(strCountry: String, mField: UITextField) {
        arySelCountryCode[mField.tag] = strCountry
        mField.text = pubClass.getLang("countryname_" + strCountry)
        
        // TODO, Table data source 重整
    }
    
    /**
     * act, btn 彈出選擇 YYMM 視窗
     */
    @IBAction func actYYMM(sender: UIButton) {
    }
    
    /**
     * act, btn, Table 滑動至 section 1
     */
    @IBAction func actTot(sender: UIButton) {
    }
    
    /**
     * act, btn 國別選擇, 彈出選擇 國別選擇 視窗
     */
    @IBAction func actCountry(sender: UIBarButtonItem) {
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