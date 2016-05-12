//
// CollectionView 直接獨立一個 class 處理
//

import UIKit

/**
 * 經銷商業績排行主頁面
 */
class TopRank: UIViewController, TopRankColtViewDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var colviewCountry: TopRankColtView!
    @IBOutlet weak var labCalDate: UILabel!
    @IBOutlet weak var segmDegree: UISegmentedControl!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var dictTableData: Dictionary<String, Dictionary<String, String>> = [:]
    
    // 今日or前月, today/premonth
    private var aryFlagToday = ["today", "premonth"]
    private var currFlagToday: String!
    
    // 國別職級資料
    private var dictDegree: Dictionary<String, Array<String>> = [:]  // 國別職級資料
    private var aryDegree: Array<String> = []  // 目前選擇的國別職級 array
    
    // 其他參數
    private var aryPriv: Array<String>! // user 國別權限 array
    private var currCountryCode = ""  // 目前選擇的國別 code
    private var aryAllowCountry: Array<String>!  // 可點選查看下線資料的國別
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 取得國別權限 ary, 實體化與設定 collectView 內容
        aryPriv = pubClass.getAppDelgVal("V_PRIV") as! Array<String>
        colviewCountry.delgTopRankColtView = self
        colviewCountry.initData(aryPriv)
        currCountryCode = aryPriv[0]
        
        // 其他參數
        currFlagToday = aryFlagToday[0]
        labNoData.hidden = true
        
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
     * 檢查與重新產生頁面資料
     */
    private func chkHaveData() {
        // 統計日期
        labCalDate.text = dictAllData[currFlagToday] as? String
        
        // 可點選查看下線資料的國別
        aryAllowCountry = dictAllData["agentcountry"] as! Array<String>
        
        // 產生 degree all data, 重整 degree Segment
        dictDegree = dictAllData["degree"] as! Dictionary<String, Array<String>>
        aryDegree = dictDegree[currCountryCode]!
        segmDegree.removeAllSegments()
        
        for loopi in (0..<aryDegree.count) {
            segmDegree.insertSegmentWithTitle(aryDegree[loopi], atIndex: loopi, animated: true)
        }
        
        segmDegree.selectedSegmentIndex = 0
        
        // tableView / collectView 重整
        resetTableData()
        colviewCountry.reloadData()
    }
    
    /**
     * 重整 table 資料
     */
    private func resetTableData() {
        // Cell 是否可點選
        tableList.allowsSelection = false
        for strCountry in aryAllowCountry {
            if (currCountryCode == strCountry) {
                tableList.allowsSelection = true
                
                break;
            }
        }
        
        
        // 取得目前國別，全部職級資料
        let dictTmp = dictAllData["data"]![currFlagToday]!
        
        // 檢查指定國別，職級資料是否有'NULL'(該職級沒有排名資料)
        dictTableData = [:]
        
        if let aryCountryAllData = dictTmp![currCountryCode] as? Array<AnyObject> {
            // 目前職級的排名 array data, 產生 Table data source
            if let dictTmp = aryCountryAllData[segmDegree.selectedSegmentIndex] as? Dictionary<String, Dictionary<String, String>> {
                dictTableData = dictTmp
            }
        }

        tableList.reloadData()
        
        if (dictTableData.count > 0) {
            labNoData.hidden = true
            
            let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: 0)
            tableList.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            labNoData.hidden = false
        }
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "toprank"
        mParam["act"] = "toprank_getdata"
        
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
     * #mark: TopRankColtView Delegate, 國別選擇 collectView 點取 Cell
     */
    func ColtViewCellSelect(countryCode: String) {
        currCountryCode = countryCode
        chkHaveData()
    }
    
    /**
     * #mark: UITableView Delegate, Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (dictTableData.count > 0) ? 1 : 0
    }
    
    /**
     * #mark: UITableView Delegate, section 內的 row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
         return  dictTableData.count
    }
    
    /**
     * #mark: UITableView Delegate, UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (dictTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let strRank = String(indexPath.row + 1)
        var dictItem = dictTableData[strRank]!
        dictItem["rank"] = strRank

        let mCell = tableView.dequeueReusableCellWithIdentifier("cellTopRank", forIndexPath: indexPath) as! TopRankCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
    /**
     * #mark: TableView VC delegate, table view Item 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let strRank = String(indexPath.row + 1)
        let dictItem = dictTableData[strRank]!
        
        // 設定跳轉頁面
        self.performSegueWithIdentifier("TopRankDetail", sender: dictItem)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "TopRankDetail") {
            let mVC = segue.destinationViewController as! TopRankDetail
            mVC.agentId = sender!["id"] as! String
            mVC.countryCode = currCountryCode
            mVC.calDate = dictAllData[currFlagToday] as! String
            
            return
        }
        
        return
    }
    
    /**
     * act, btn '職級'
     */
    @IBAction func actDegree(sender: UISegmentedControl) {
        resetTableData()
    }
    
    /**
     * act, btn Group 今日/前月
     */
    @IBAction func actGropToday(sender: UIBarButtonItem) {
        currFlagToday = aryFlagToday[sender.tag]
        
        // 全部資料重整
        chkHaveData()
    }
    
    /**
     * act, btn '刷新'
     */
    @IBAction func actReload(sender: UIBarButtonItem) {
        // field 與相關參數重設
        currCountryCode = aryPriv[0]
        currFlagToday = aryFlagToday[0]
        
        colviewCountry.initData(aryPriv)
        let mIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        colviewCountry.scrollToItemAtIndexPath(mIndexPath, atScrollPosition: .Left, animated: true)
        
        // 重新 HTTP 連線
        bolReload = true
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