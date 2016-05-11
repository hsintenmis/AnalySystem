//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 歷史業績查詢, 金額加總資料 TableView Cell
 */
class HistorySaleTotCell: UITableViewCell {
    @IBOutlet weak var labNT_0: UILabel!
    @IBOutlet weak var labNT_1: UILabel!
    @IBOutlet weak var labNT_2: UILabel!
    @IBOutlet weak var labORG_0: UILabel!
    @IBOutlet weak var labORG_1: UILabel!
    @IBOutlet weak var labORG_2: UILabel!
    
    @IBOutlet weak var labYYMMpreiod: UILabel!
    @IBOutlet weak var labNameTot: UILabel!
    
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
        labYYMMpreiod.text = dictItem["yymm"] as? String
        
        labNT_0.text = pubClass.fmtCurrency(dictItem["NT_0"] as! String)
        labNT_1.text = pubClass.fmtCurrency(dictItem["NT_1"] as! String)
        labNT_2.text = pubClass.fmtCurrency(dictItem["NT_2"] as! String)
        labORG_0.text = pubClass.fmtCurrency(dictItem["ORG_0"] as! String)
        labORG_1.text = pubClass.fmtCurrency(dictItem["ORG_1"] as! String)
        labORG_2.text = pubClass.fmtCurrency(dictItem["ORG_2"] as! String)
    }
    
}