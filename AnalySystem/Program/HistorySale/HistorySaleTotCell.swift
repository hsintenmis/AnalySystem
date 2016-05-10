//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 歷史業績查詢, 金額加總資料 TableView Cell
 */
class HistorySaleTotCell: UITableViewCell {
    @IBOutlet weak var labYYMM: UILabel!
    
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