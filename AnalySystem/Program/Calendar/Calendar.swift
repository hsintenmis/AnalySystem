//
// TableView
//

import UIKit

/**
 * 集團全球行事曆
 * <P>
 * 伺服器回傳主要資料如下：<br>
 * 'aryyymm' : array 'YYMM'<br>
 * 'curryymm' : 今天的日期 YYMM <br>
 * 'data' : 日期對應的 array data<br>
 */
class Calendar: UIViewController, CalendarViewDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labMMDD: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    
    // 目前 '日期'資料的 dict data
    private var currDictDD: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mCalendarView: CalendarView!
    private var currYMD: Dictionary<String, String> = [:]  // YY, MM, DD
    private var dictAllDataMM: Dictionary<String, AnyObject> = [:]  // 全部月份資料
    private var aryAllCountryCode: Array<String>!  // 全部國別代碼
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableCell 自動調整高度
        tableList.estimatedRowHeight = 60.0
        tableList.rowHeight = UITableViewAutomaticDimension
        
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
     * 檢查是否有資料 + 頁面重新整理
     */
    private func chkHaveData() {
        // 全部國別代碼
        aryAllCountryCode = dictAllData["countrycode"] as! Array<String>
        
        // 重新設定今天日期 dict data
        let strYMD = dictAllData["curryymmdd"] as! String
        
        self.currYMD["YY"] = self.pubClass.subStr(strYMD, strFrom: 0, strEnd: 4)
        self.currYMD["MM"] = self.pubClass.subStr(strYMD, strFrom: 4, strEnd: 6)
        self.currYMD["DD"] = self.pubClass.subStr(strYMD, strFrom: 6, strEnd: 8)
        
        // 重新整理 calendar data
        dictAllDataMM = dictAllData["data"] as! Dictionary<String, AnyObject>
        let aryBeginEndYM = dictAllData["aryyymm"] as! Array<String>
        let strBeginYM = aryBeginEndYM[0]
        let strEndYM = aryBeginEndYM[(aryBeginEndYM.count - 1)]
        
        mCalendarView.initCalendar(currYMD, allDataMM: dictAllDataMM, aryBeginEndYM: [strBeginYM, strEndYM])
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "calendar"
        mParam["act"] = "calendar_getdata"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            var errMsg = self.pubClass.getLang("err_trylatermsg")
            
            if (dictRS["result"] as! Bool != true) {
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            var dictData: Dictionary<String, AnyObject> = [:]
            let dictTmpRSData = dictRS["data"] as! Dictionary<String, AnyObject>

            if let dictTmp = dictTmpRSData["content"] as? Dictionary<String, AnyObject> {
                dictData = dictTmp
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
            }

            /* 解析正確的 http 回傳結果 */
            self.dictAllData = dictData
            
            // 頁面資料重新整理
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
        let dictItem = aryTableData[indexPath.row]
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCalendarTable", forIndexPath: indexPath) as! CalendarTableCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
    /**
     * #mark: CalendarViewDelegate Delegate, 月曆資料變動
     */
    func CalendarDataChange(dictYMD: Dictionary<String, String>!) {
        currYMD = dictYMD
        
        let strDD = String(Int(dictYMD["DD"]!)!)
        let strMM = pubClass.getLang("mm_" + dictYMD["MM"]!)
        labMMDD.text = String(format: pubClass.getLang("fmt_MD"), arguments: [strMM, strDD])
        
        // 產生 Table 需要的資料
        currDictDD = [:]
        
        let strKey = "key" + currYMD["YY"]! + currYMD["MM"]!
        
        if let aryTmp = dictAllDataMM[strKey] as? Array<Dictionary<String, AnyObject>> {
            for dictTmp in aryTmp {
                let str02DD = String(format: "%02d", Int(dictTmp["DD"] as! String)!)
                
                if (dictYMD["DD"] == str02DD) {
                    currDictDD = dictTmp["data"] as! Dictionary<String, AnyObject>
                    break
                }
            }
        }

        // loop 全部國別，檢查該國有無資料
        aryTableData = []
        
        if (currDictDD.count > 0) {
            for strCountry in aryAllCountryCode {
                if let dictTmp = currDictDD[strCountry] as? Dictionary<String, AnyObject> {
                    let aryTitle = dictTmp["title"] as! Array<String>
                    
                    var dictData: Dictionary<String, AnyObject> = [:]
                    dictData["country"] = pubClass.getLang("countryname_" + strCountry)
                    var strTitle = ""
                    
                    for loopi in (0..<aryTitle.count) {
                        strTitle = aryTitle[loopi]
                        if (loopi < (aryTitle.count - 1)) {
                            strTitle += "\n"
                        }
                    }
                    
                    dictData["title"] = strTitle
                    
                    aryTableData.append(dictData)
                }
            }
        }
        
        // Table 資料重整
        tableList.reloadData()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "CalendarView") {
            mCalendarView = segue.destinationViewController as! CalendarView
            mCalendarView.delgCalendar = self
            
            return
        }
        
        return
    }
    
    /**
     * act, btn '今日'
     */
    @IBAction func actToday(sender: UIBarButtonItem) {
        mCalendarView.actToday()
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