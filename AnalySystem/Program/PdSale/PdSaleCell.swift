//
// UITableViewCell
//

import UIKit

/**
 * 商品銷售排行, 指定國別商品排名列表, TableView Cell
 */
class PdSaleCell: UITableViewCell {
    @IBOutlet weak var edRank: UITextField!
    
    @IBOutlet weak var labName_qty: UILabel!
    @IBOutlet weak var labId_qty: UILabel!
    @IBOutlet weak var labQty_qty: UILabel!
    @IBOutlet weak var labTot_qty: UILabel!
    @IBOutlet weak var labNt_qty: UILabel!
    
    @IBOutlet weak var labName_tot: UILabel!
    @IBOutlet weak var labId_tot: UILabel!
    @IBOutlet weak var labQty_tot: UILabel!
    @IBOutlet weak var labTot_tot: UILabel!
    @IBOutlet weak var labNt_tot: UILabel!
    
    private var pubClass = PubClass()
    
    /**
     * Cell Load
     */
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /**
     * 初始與設定 Cell
     */
    func initView(dictItem: Dictionary<String, AnyObject>!) {
        let dictQty = dictItem["qty"] as! Dictionary<String, String>
        let dictTot = dictItem["tot"] as! Dictionary<String, String>
        let dictPdName = dictItem["pdname"] as! Dictionary<String, String>
        
        edRank.text = String(format: pubClass.getLang("fmt_rankname"), dictItem["rank"] as! String)

        
        var strId = dictQty["id"]!
        labName_qty.text = dictPdName[strId]
        labId_qty.text = strId
        labQty_qty.text = dictQty["qty"]
        labTot_qty.text = pubClass.fmtDelPoint(dictQty["tot"], bolUnit: false)
        labNt_qty.text = pubClass.fmtDelPoint(dictQty["tot_nt"], bolUnit: false)
        
        strId = dictTot["id"]!
        labName_tot.text = dictPdName[strId]
        labId_tot.text = strId
        labQty_tot.text = dictTot["qty"]
        labTot_tot.text = pubClass.fmtDelPoint(dictTot["tot"], bolUnit: false)
        labNt_tot.text = pubClass.fmtDelPoint(dictTot["tot_nt"], bolUnit: false)
    }
    
}