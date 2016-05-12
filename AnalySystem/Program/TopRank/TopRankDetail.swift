//
// TableView
//

import UIKit

/**
 * 經銷商業績排行, 本人/下線 積分查詢
 * HTTP 參數: agentid, strCurrCountry, flagCalDate
 */
class TopRankDetail: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labEmail: UILabel!
    @IBOutlet weak var labAddr: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 傳入
    var agentId: String!
    var countryCode: String!
    var calDate: String!
    
    // 本頁面需要的資料集
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    private var bolReload = true // 頁面是否需要 http reload
    
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
        // agent 基本資料 field val 設定
        let dictAgent = dictAllData["agent"] as! Dictionary<String, AnyObject>
        
        labName.text = dictAgent["description"] as? String
        labDegree.text = dictAgent["degree_name"] as? String
        labTel.text = dictAgent["tel"] as? String
        labEmail.text = dictAgent["email"] as? String
        labAddr.text = dictAgent["addr"] as? String
 
        // 下線資料
        aryTableData = dictAllData["pv"] as! Array<Dictionary<String, AnyObject>>
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
        mParam["page"] = "teampvlist"
        mParam["act"] = "teampvlist_getdata"
        
        mParam["agentid"] = agentId
        mParam["strCurrCountry"] = countryCode
        mParam["flagCalDate"] = calDate
        
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
        return  aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate, UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let dictItem = aryTableData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellTopRankDetail", forIndexPath: indexPath) as! TopRankDetailCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
    /**
     * act, btn '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}