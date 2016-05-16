//
// UITableView VC
//

import UIKit

/**
 * 商品銷售排行, 指定國別商品排名列表
 */
class PdSaleTable: UITableViewController {
    
    // @IBOutlet
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent設定, 本頁面 tableView 需要的資料集
    var dictAllData: Dictionary<String, AnyObject>!
    var dictPdName: Dictionary<String, String>!  // 商品編號對應的名稱

    // 其他參數
    private var aryRankQty: Array<Dictionary<String, String>>!
    private var aryRankTot: Array<Dictionary<String, String>>!
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table 資料重新整理產生
        aryRankQty = dictAllData["sort_qty"] as! Array<Dictionary<String, String>>
        aryRankTot = dictAllData["sort_tot"] as! Array<Dictionary<String, String>>
        
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
        
    }
    
    /**
     * #mark: UITableView Delegate, Section 的數量
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (aryRankQty.count > 0) ? 1 : 0
    }
    
    /**
     * #mark: UITableView Delegate, section 內的 row 數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return  aryRankQty.count
    }
    
    /**
     * #mark: UITableView Delegate, UITableView, Cell 內容
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryRankQty.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        var dictItem: Dictionary<String, AnyObject> = [:]
        let position = indexPath.row
        
        dictItem["rank"] = String(position + 1)
        dictItem["qty"] = aryRankQty[position]
        dictItem["tot"] = aryRankTot[position]
        dictItem["pdname"] = dictPdName
        
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPdSale", forIndexPath: indexPath) as! PdSaleCell
        
        mCell.initView(dictItem)
        
        return mCell
    }
    
}