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
        
    }
    
}