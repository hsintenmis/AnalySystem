//
// TableView
//

import UIKit

/**
 * 台灣總裁列表 - 下線列表
 */
class AgentTWDetail: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labEmail: UILabel!
    @IBOutlet weak var labAddr: UILabel!
    @IBOutlet weak var labPv: UILabel!
    @IBOutlet weak var labTeam: UILabel!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 傳入
    var dictAllData: Dictionary<String, AnyObject>!
    var aryDegree: Array<String>!
    
    // 本頁面需要的資料集
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    
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
        
        // 頁面資料與 table data source 設定
        let strTPV = dictAllData["team_pv"] as! String
        
        labName.text = dictAllData["description"] as? String
        labTel.text = dictAllData["m_phone"] as? String
        labEmail.text = dictAllData["email"] as? String
        labAddr.text = dictAllData["addr1"] as? String
        labPv.text = dictAllData["per_pv"] as? String
        labTeam.text = strTPV
        
        let intLV = Int(dictAllData["level"] as! String)!
        labDegree.text = aryDegree[intLV]
        
        // 顏色
        let mColor = (Int(strTPV)! > 0) ? pubClass.ColorHEX(myColor.GRAY333.rawValue) : pubClass.ColorHEX(myColor.RedDark.rawValue)
        labPv.textColor = mColor
        labTeam.textColor = mColor
        labName.textColor = mColor
        
        // table data source
        if let aryTmp = dictAllData["downline"] as? Array<Dictionary<String, AnyObject>> {
            aryTableData = aryTmp
            
            labNoData.hidden = true
        }
    }
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        
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
        dictItem["degree_name"] = aryDegree[Int(dictItem["level"] as! String)!]
        
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellAgentTWDetail", forIndexPath: indexPath) as! AgentTWDetailCell
        
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