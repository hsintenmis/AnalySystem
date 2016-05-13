//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 直銷商搜尋 TableView Cell
 */
class SearchAgentCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labEmail: UILabel!
    @IBOutlet weak var labAddr: UILabel!
    @IBOutlet weak var labPv: UILabel!
    
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
        labTel.text = dictItem["m_tel"] as? String
        labEmail.text = dictItem["email"] as? String
        labAddr.text = dictItem["addr"] as? String
        
        // 設定 pv 文字
        let aryPv = dictItem["pv"] as! Array<Array<String>>
        var strPv = ""
        
        for aryTmp in aryPv {
            let strTmp = aryTmp[0] + ", pv: " + aryTmp[1] + "\n"
            strPv = strPv + strTmp
        }
        
        labPv.text = strPv
    }
    
}