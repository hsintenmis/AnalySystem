//
// VC 包含 ContainerView
//

import UIKit

/**
 * 即時業績主頁面
 */
class BranchSale: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    @IBOutlet weak var segmToday: UISegmentedControl!
    @IBOutlet weak var swchPriceUnit: UISwitch!
    @IBOutlet weak var labPriceUnit: UILabel!
    @IBOutlet weak var labSumDate: UILabel!
    @IBOutlet weak var labCalDate: UILabel!
    @IBOutlet weak var labMsgGray: UILabel!
    @IBOutlet weak var labMsgGreen: UILabel!
    
    @IBOutlet weak var btnNameGlobal: UIBarButtonItem!
    @IBOutlet weak var btnNameTW: UIBarButtonItem!
    @IBOutlet weak var btnNameMY: UIBarButtonItem!
    
    @IBOutlet weak var btnNameAMERICA: UIBarButtonItem!
    @IBOutlet weak var btnNameASIA: UIBarButtonItem!
    @IBOutlet weak var btnNameCHINA: UIBarButtonItem!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<String> = []
    private var dictSum: Dictionary<String, AnyObject> = [:]  // 金額加總
    
    // 國別對應的 branch code
    private var dictBranchCode: Dictionary<String, Array<String>> = [:]
    
    // 其他參數
    private var aryAllBranch = ["all", "AMERICA", "ASIA", "CHINA", "TW", "MY"]
    private var strCurrBranch = "all"  // all, TW, MY
    private var isToday = "Y"  // Y=今日, N=前月
    private var isPriceUnit = false  // 是否切換 '萬元'
    private var aryCalDate: Array<String>!
    
    // 2016/05/31, 特殊區域 與 button, 有順序對應
    private var dictAreaBranch: Dictionary<String, Array<String>> = [:]
    private var arySpecArea: Array<String>!
    private var arySpecAreaBtn: Array<UIBarButtonItem>!

    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arySpecAreaBtn = [btnNameAMERICA, btnNameASIA, btnNameCHINA]
        
        // 2016/05/31, 新增 亞太/美洲/中國
        arySpecArea = pubClass.getAppDelgVal("V_AREACODENAME") as! Array<String>
        dictBranchCode = pubClass.getAppDelgVal("V_AREABRANCH") as! Dictionary<String, Array<String>>
        
        // 對應的 branch code
        dictBranchCode["all"] = pubClass.getAppDelgVal("V_PRIV") as? Array<String>
        dictBranchCode["TW"] = pubClass.aryOfficeTW
        dictBranchCode["MY"] = pubClass.aryOfficeMY

        // 檢查權限, TW/MY
        for strBranch in dictBranchCode["all"]! {
            if (strBranch == "TW") {
                btnNameTW.enabled = true
            }
            if (strBranch == "MY") {
                btnNameMY.enabled = true
            }
        }
        
        // 檢查權限, 亞太/美洲/中國
        for loopi in (0..<arySpecArea.count) {
            let aryOffice = dictBranchCode[arySpecArea[loopi]]!
            let numsTot = aryOffice.count
            var numsTmp = 0

            for strOffice0 in aryOffice {
                for strOffice1 in dictBranchCode["all"]! {
                    if (strOffice0 == strOffice1) {
                        numsTmp += 1
                    }
                }
            }
            
            if (numsTot == numsTmp) {
                arySpecAreaBtn[loopi].enabled = true
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
     * 檢查是否有資料, 預設資料為: '全球'+'當日' => dict['tot']['Y']
     */
    private func chkHaveData() {
        // 檢查是否有資料
        if let _ = dictAllData[strCurrBranch]![isToday] as? Dictionary<String, AnyObject> {
            aryTableData = dictBranchCode[strCurrBranch]!
            
            calTot()
        }
        else {
            aryTableData = []
            pubClass.popIsee(self, Msg: pubClass.getLang("nodata"))
            return
        }
        
        // 統計日期文字
        labCalDate.text = aryCalDate[0]
        
        // tableview reload
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
        mParam["page"] = "branchsale"
        mParam["act"] = "branchsale_getdata"
        
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
            
            // 特殊 branch TW/MY 重整資料
            let dictBranch_Y = dictData["branch"]!["Y"] as! Dictionary<String, AnyObject>
            let dictBranch_N = dictData["branch"]!["N"] as! Dictionary<String, AnyObject>
            
            var dictTW: Dictionary<String, AnyObject> = [:]
            dictTW["Y"] = dictBranch_Y["TW"]
            dictTW["N"] = dictBranch_N["TW"]
            
            var dictMY: Dictionary<String, AnyObject> = [:]
            dictMY["Y"] = dictBranch_Y["MY"]
            dictMY["N"] = dictBranch_N["MY"]
            
            var tmpAllData: Dictionary<String, AnyObject> = [:]
            tmpAllData["all"] = dictData["tot"]
            tmpAllData["TW"] = dictTW
            tmpAllData["MY"] = dictMY
            
            // 特殊區域
            let dictTot_Y = dictData["tot"]!["Y"] as! Dictionary<String, AnyObject>
            let dictTot_N = dictData["tot"]!["N"] as! Dictionary<String, AnyObject>
            
            for strArea in self.arySpecArea {
                var dictAreaData: Dictionary<String, Dictionary<String, AnyObject>> = [:]
                dictAreaData["Y"] = [:]
                dictAreaData["N"] = [:]
                
                for strAreaOffice in self.dictBranchCode[strArea]! {
                    dictAreaData["Y"]![strAreaOffice] = dictTot_Y[strAreaOffice]
                    dictAreaData["N"]![strAreaOffice] = dictTot_N[strAreaOffice]
                }
                
                tmpAllData[strArea] = dictAreaData
            }
            
            // 統計日期文字設定到 array
            let strDate0 = self.pubClass.formatDateWithStr(dictData["today"] as! String, type: 8)
            let strDate1 = self.pubClass.formatDateWithStr(dictData["premonth"] as! String, type: 8)
            self.aryCalDate = [strDate0, strDate1]
            
            self.dictAllData = tmpAllData
            self.chkHaveData()
        })
    }
    
    /**
     * 全部金額加總
     */
    private func calTot() {
        let aryIs_YN = ["Y", "N"]
        let aryField = ["DD_NT", "MM_NT", "YY_NT","DD_ORG", "MM_ORG", "YY_ORG","DD_NT_r", "MM_NT_r", "YY_NT_r","DD_ORG_r", "MM_ORG_r", "YY_ORG_r"]
        
        var aryCountry = ["all"]
        
        if (btnNameTW.enabled) {
            aryCountry.append("TW")
        }
        if (btnNameMY.enabled) {
            aryCountry.append("MY")
        }
        
        // 特殊區域
        for loopi in (0..<arySpecAreaBtn.count)  {
            if (arySpecAreaBtn[loopi].enabled) {
                aryCountry.append(arySpecArea[loopi])
            }
        }
        
        // 金額加總計算
        for strFlag in aryIs_YN {
            var dictSum_YN: Dictionary<String, AnyObject> = [:]
            
            // 取得欄位資料加總
            for strCountry in aryCountry {
                var dictSum_Country: Dictionary<String, AnyObject> = [:]
                
                let dictAllCountryData = dictAllData[strCountry]!
                let dictAll_YNdata = dictAllCountryData[strFlag]!
                let aryBranchCode = dictBranchCode[strCountry]!
                let nums = aryField.count

                /*
                if (strCountry == "all") {
                    nums = 3
                }
                */
        
                // loop 欄位
                for loopi in (0..<nums) {
                    let strField = aryField[loopi]
                    var totPrice: Double = 0
                    
                    // loop 各國別/營業處資料
                    for strBranch in aryBranchCode {
                        
                        // 判別該國別/營業處是否有資料
                        if let dictAllPrice = dictAll_YNdata![strBranch] as? Dictionary<String, AnyObject> {
                            
                            let mPrice = Double(dictAllPrice[strField] as! String)!
                            totPrice = totPrice + mPrice
                        }
                    }
                    
                    dictSum_Country[strField] = String(format: "%.2f", Double(totPrice))
                }
                
                dictSum_YN[strCountry] = dictSum_Country
            }
            
            dictSum[strFlag] = dictSum_YN
        }
    }
    
    /**
     * #mark: UITableView Delegate, Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (aryTableData.count < 1) {
            return 0
        }
        
        return 2
    }
    
    /**
     * #mark: UITableView Delegate, section 內的 row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if (section == 1) {
            return 1
        }
        
        return aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate, UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let strOffice = aryTableData[indexPath.row]
        var dictItem: Dictionary<String, AnyObject> = [:]
        
        // 國別 or 加總 資料
        if (indexPath.section == 0) {
            let dictBranchdata = dictAllData[strCurrBranch]![isToday] as! Dictionary<String, AnyObject>
            if let dictTmp = dictBranchdata[strOffice] as? Dictionary<String, AnyObject> {
                dictItem = dictTmp
            }
            
            dictItem["isSumData"] = false
        }
        else {
            dictItem = dictSum[isToday]![strCurrBranch] as! Dictionary<String, AnyObject>
            dictItem["isSumData"] = true
        }
        
        dictItem["branch"] = strCurrBranch
        dictItem["office"] = strOffice
        dictItem["isUnit"] = isPriceUnit
        
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellBranchSale", forIndexPath: indexPath) as! BranchSaleCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1) {
            return "-- " + pubClass.getLang("totsalesum") + " --"
        }
        
        return pubClass.getLang("countryname_" + strCurrBranch)
    }
    
    /**
     * act, Segment '今日/前月'
     */
    @IBAction func actSegmToday(sender: UISegmentedControl) {
        isToday = (sender.selectedSegmentIndex == 0) ? "Y" : "N"
        labCalDate.text = aryCalDate[sender.selectedSegmentIndex]
        tableList.reloadData()
    }
    
    /**
     * act, Switch '萬元'
     */
    @IBAction func actSwchPriceUnit(sender: UISwitch) {
        isPriceUnit = sender.on
        tableList.reloadData()
    }
    
    /**
     * act, btn '刷新'
     */
    @IBAction func actReload(sender: UIBarButtonItem) {
        // field 與相關參數重設
        isToday = "Y"
        strCurrBranch = "all"
        aryTableData = dictBranchCode[strCurrBranch]!
        segmToday.selectedSegmentIndex = 0
        swchPriceUnit.on = false
        
        // 重新 HTTP 連線
        reConnHTTP()
    }
    
    /**
     * act, btn '主選單'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    /**
     * act, btn Group, 點取 全球/TW/MY
     */
    @IBAction func actGrpBranch(sender: UIBarButtonItem) {
        strCurrBranch = aryAllBranch[sender.tag]
        aryTableData = dictBranchCode[strCurrBranch]!
        tableList.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}