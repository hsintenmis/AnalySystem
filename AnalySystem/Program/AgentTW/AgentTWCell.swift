//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 台灣總裁列表與搜尋 TableView Cell
 */
class AgentTWCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    @IBOutlet weak var labNo: UILabel!
    @IBOutlet weak var labPer: UILabel!
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
        labName.text = dictItem["description"] as? String
        labDegree.text = dictItem["degree_name"] as? String
        labNo.text = dictItem["no"] as? String
        labPer.text = dictItem["per_pv"] as? String
        
        let strTPV = dictItem["team_pv"] as! String
        labTeam.text = strTPV
        
        let mColor = (Int(strTPV)! > 0) ? pubClass.ColorHEX(myColor.GRAY333.rawValue) : pubClass.ColorHEX(myColor.RedDark.rawValue)
        labPer.textColor = mColor
        labTeam.textColor = mColor
        labName.textColor = mColor
    }
    
}