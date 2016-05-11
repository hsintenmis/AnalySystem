//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 歷史業績查詢, 三個國別的資料 TableView Cell
 */
class HistorySaleCell: UITableViewCell {
    @IBOutlet weak var labYYMM: UILabel!
    
    @IBOutlet weak var labNT_0: UILabel!
    @IBOutlet weak var labNT_1: UILabel!
    @IBOutlet weak var labNT_2: UILabel!
    @IBOutlet weak var labORG_0: UILabel!
    @IBOutlet weak var labORG_1: UILabel!
    @IBOutlet weak var labORG_2: UILabel!
    
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
        labNT_0.text = pubClass.fmtCurrency(dictItem["NT_0"] as! String)
        labNT_1.text = pubClass.fmtCurrency(dictItem["NT_1"] as! String)
        labNT_2.text = pubClass.fmtCurrency(dictItem["NT_2"] as! String)
        labORG_0.text = pubClass.fmtCurrency(dictItem["ORG_0"] as! String)
        labORG_1.text = pubClass.fmtCurrency(dictItem["ORG_1"] as! String)
        labORG_2.text = pubClass.fmtCurrency(dictItem["ORG_2"] as! String)
        
        let strYYMM = dictItem["yymm"] as! String
        labYYMM.text = pubClass.subStr(strYYMM, strFrom: 0, strEnd: 4) + "/" + pubClass.subStr(strYYMM, strFrom: 4, strEnd: 6)
    }

}