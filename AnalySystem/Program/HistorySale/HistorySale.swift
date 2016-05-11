//
// VC 包含 ContainerView
//

import UIKit

/**
 * 歷史業績主頁面
 */
class HistorySale: UIViewController, PickerCountryDelegate, PickerYMPeriodDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labGrayMsg: UILabel!
    @IBOutlet weak var labCurrenctMsg: UILabel!
    @IBOutlet var btnCountry: [UIButton]!
    @IBOutlet weak var btnYYMM: UIBarButtonItem!
    @IBOutlet weak var btnTot: UIBarButtonItem!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<AnyObject> = [] // YYMM array 資料
    private var dictTotPriceData: Dictionary<String, String> = [:]  //sect1 加總資料
    
    // 記錄目前 YYMM 起始結束的 position array data
    private var aryCurrYYMM: Array<Int>!
    
    // 其他參數
    private var aryYYMM: Array<String> = [] // YYMM 起始 array data
    private var aryPriv: Array<String>!
    private var aryIndexYM = [0, 24]  // YYMM 起始 position
    private var aryCurrCountry: Array<String> = []  // 目前選擇的國別
    private var tagBtnCountry = 0  // 目前點取 '選擇國別' btn tag
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableCell 自動調整高度
        tableList.estimatedRowHeight = 60.0
        tableList.rowHeight = UITableViewAutomaticDimension
        
        // 設定 user 國別權限 array, country btn statu
        aryPriv = pubClass.getAppDelgVal("V_PRIV") as! Array<String>
        for loopi in (0..<3) {
            var strTitle = "--"
            btnCountry[loopi].enabled = false
            
            if (aryPriv.count > loopi) {
                btnCountry[loopi].enabled = true
                aryCurrCountry.append(aryPriv[loopi])
                strTitle = pubClass.getLang("countryname_" + aryPriv[loopi])
            }
            
            btnCountry[loopi].setTitle(strTitle, forState: UIControlState.Normal)
        }
        
        // 產生 YYMM 起始 array data
        let strToday = pubClass.getDevToday()
        let strLastYYMM = pubClass.subStr(strToday, strFrom: 0, strEnd: 6)
        var strCurrYYMM = pubClass.D_YYMM_START
        
        while (strLastYYMM >= strCurrYYMM) {
            let YY = pubClass.subStr(strCurrYYMM, strFrom: 0, strEnd: 4)
            let MM = pubClass.subStr(strCurrYYMM, strFrom: 4, strEnd: 6)
            let intMM = Int(MM)!
            
            aryYYMM.append((YY + MM))
            
            if ((intMM + 1) > 12) {
                strCurrYYMM = String(Int(YY)! + 1) + "01"
            } else {
                strCurrYYMM = YY + String(format: "%02d", (intMM + 1))
            }
        }
        
        aryYYMM = aryYYMM.reverse()
        
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
     * 根據 YYMM 區間，重新產生 Table data source
     */
    private func chkHaveData() {
        // 根據 YYMM 起始 position, 產生 table data source
        aryCurrYYMM = []
        aryTableData = []
        var aryTot: Dictionary<String, Float32> = [:]
        
        for loopi in (0..<3) {
            aryTot["NT_" + String(loopi)] = 0.0
            aryTot["ORG_" + String(loopi)] = 0.0
        }
        
        for intIndex in (aryIndexYM[0]..<(aryIndexYM[1] + 1)) {
            aryCurrYYMM.append(intIndex)
            
            // 產生目前已選擇的國別的資料
            var dictYYMMData: Dictionary<String, String> = [:]  // YYMM data
            var dictTotData: Dictionary<String, String> = [:]  // 加總 data
            
            for loopi in (0..<3) {
                let strLoopi = String(loopi)
                
                dictYYMMData["NT_" + strLoopi] = "--"
                dictYYMMData["ORG_" + strLoopi] = "--"
                dictTotData["NT_" + strLoopi] = "--"
                dictTotData["ORG_" + strLoopi] = "--"
                
                if (aryCurrCountry.count > loopi) {
                    let strCountry = aryCurrCountry[loopi]
                    let keyNT = "NT_" + strLoopi
                    let keyORG = "ORG_" + strLoopi
                    
                    let aryCountryData = dictAllData[strCountry] as! Array<Dictionary<String, AnyObject>>  // country ary
                    let lastPosition = (aryCountryData.count - 1) // last position
                    
                    // 加入 YYMM data
                    if (lastPosition >= intIndex) {
                        let dictYYMM = aryCountryData[intIndex] as! Dictionary<String, String>
                        
                        dictYYMMData[keyNT] = dictYYMM["MM_NT"]
                        dictYYMMData[keyORG] = dictYYMM["MM_ORG"]
                        
                        // 加總金額
                        let fltNT = Float32(dictYYMM["MM_NT"]!)!
                        let fltORG = Float32(dictYYMM["MM_ORG"]!)!
                        
                        aryTot[keyNT] = aryTot[keyNT]! + fltNT
                        aryTot[keyORG] = aryTot[keyORG]! + fltORG
                    }

                }

            }
            
            aryTableData.append(dictYYMMData)
        }

        // 金額加總資料重整
        dictTotPriceData = [:]
        
        for loopi in (0..<3) {
            let strLoopi = String(loopi)
            let keyNT = "NT_" + strLoopi
            let keyORG = "ORG_" + strLoopi
            
            dictTotPriceData[keyNT] = "--"
            dictTotPriceData[keyORG] = "--"
            
            if (aryPriv.count > loopi) {
                dictTotPriceData[keyNT] = String(format: "%.02f", Float32(aryTot[keyNT]!))
                dictTotPriceData[keyORG] = String(format: "%.02f", Float32(aryTot[keyORG]!))
            }
        }
        
        // table 重整
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
        if (aryTableData.count < 1) {
            return 0
        }
        
        return (section == 0) ? aryTableData.count : 1
    }
    
    /**
     * #mark: UITableView Delegate, UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        // YYMM 資料列表
        if (indexPath.section == 0) {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellHistorySale", forIndexPath: indexPath) as! HistorySaleCell
            
            var dictItem = aryTableData[indexPath.row] as! Dictionary<String, String>
            dictItem["yymm"] = aryYYMM[aryCurrYYMM[indexPath.row]]
            
            mCell.initView(dictItem)
            
            return mCell
        }
        
        // 金額加總列表
        if (indexPath.section == 1) {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellHistorySaleTot", forIndexPath: indexPath) as! HistorySaleTotCell
            
            var dictItem = dictTotPriceData
            let strYM_S = aryYYMM[aryIndexYM[0]]
            let strYM_E = aryYYMM[aryIndexYM[1]]
            
            dictItem["yymm"] =
                pubClass.subStr(strYM_S, strFrom: 0, strEnd: 4) + " " +
                pubClass.getLang("mm_" + pubClass.subStr(strYM_S, strFrom: 4, strEnd: 6)) + " ~ " +
                pubClass.subStr(strYM_E, strFrom: 0, strEnd: 4) + " " +
                pubClass.getLang("mm_" + pubClass.subStr(strYM_E, strFrom: 4, strEnd: 6))
                
            mCell.initView(dictItem)
            
            return mCell
        }
        
        return UITableViewCell()
    }
    
    /**
     * #mark: 選擇國別 PickerCountryDelegate Delegate
     */
    func doneSelect(strCountry: String) {
        aryCurrCountry[tagBtnCountry] = strCountry
        btnCountry[tagBtnCountry].setTitle(pubClass.getLang("countryname_" + strCountry), forState: UIControlState.Normal)
        
        // table 重整
        chkHaveData()
    }
    
    /**
     * #mark: 選擇日期區間, PickerYMPeriodDelegate Delegate
     */
    func doneDateSelect(aryPosition: Array<Int>) {
        aryIndexYM = aryPosition
        aryIndexYM = aryIndexYM.sort()
        
        // table 重整
        chkHaveData()
    }
    
    /**
     * act, btn Group, 點取 '選取國別'
     */
    @IBAction func actBtnCountry(sender: UIButton) {
        tagBtnCountry = sender.tag
        let strCountry = aryCurrCountry[tagBtnCountry]
        
        // 跳轉國別選擇 VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mVC = storyboard.instantiateViewControllerWithIdentifier("PickerCountry") as! PickerCountry
        
        mVC.aryCountry = aryPriv
        mVC.strSelCountry = strCountry
        mVC.delegate = self
        
        self.presentViewController(mVC, animated: true, completion: nil)
    }
    
    /**
     * act, btn 彈出選擇 YYMM 視窗
     */
    @IBAction func actYYMM(sender: UIBarButtonItem) {
        // 跳轉日期區間選擇 VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mVC = storyboard.instantiateViewControllerWithIdentifier("PickerYMPeriod") as! PickerYMPeriod
        
        mVC.aryYYMM = aryYYMM
        mVC.aryPosition = aryIndexYM
        mVC.delegate = self
        
        self.presentViewController(mVC, animated: true, completion: nil)
    }

    /**
     * act, btn, Table 滑動至 section 1
     */
    @IBAction func actTot(sender: UIBarButtonItem) {
        let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: 1)
        tableList.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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