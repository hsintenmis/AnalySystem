//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 直銷商搜尋 TableView Cell
 */
class AgentTWDetailCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labEmail: UILabel!
    @IBOutlet weak var labAddr: UILabel!
    @IBOutlet weak var labPv: UILabel!
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
        labTel.text = dictItem["m_phone"] as? String
        labEmail.text = dictItem["email"] as? String
        labAddr.text = dictItem["addr1"] as? String
        labPv.text = dictItem["per_pv"] as? String
        labDegree.text = dictItem["degree_name"] as? String
        
        let strTPV = dictItem["team_pv"] as! String
        labTeam.text = strTPV
        
        // 顏色
        let mColor = (Int(strTPV)! > 0) ? pubClass.ColorHEX(myColor.GRAY999.rawValue) : pubClass.ColorHEX(myColor.RedDark.rawValue)
        labPv.textColor = mColor
        labTeam.textColor = mColor
        labName.textColor = mColor
    }
    
}