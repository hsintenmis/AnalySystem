//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 經銷商業績排行, TableView Cell
 */
class TopRankCell: UITableViewCell {
    
    @IBOutlet weak var labRank: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labPV: UILabel!
    @IBOutlet weak var labTeam: UILabel!
    
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
        labRank.text = dictItem["rank"] as? String
        labName.text = dictItem["description"] as? String
        labPV.text = dictItem["per_pv"] as? String
        labTeam.text = dictItem["team_pv"] as? String
    }
    
}