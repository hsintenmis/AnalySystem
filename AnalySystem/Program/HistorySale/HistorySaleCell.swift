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
        labNT_0.text = dictItem["NT_0"] as? String
        labNT_1.text = dictItem["NT_1"] as? String
        labNT_2.text = dictItem["NT_2"] as? String
        labORG_0.text = dictItem["ORG_0"] as? String
        labORG_1.text = dictItem["ORG_1"] as? String
        labORG_2.text = dictItem["ORG_2"] as? String
        
        labYYMM.text = dictItem["yymm"] as? String
    }

}