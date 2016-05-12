//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 直銷商責任額列表 TableView Cell
 */
class LiabilityCell: UITableViewCell {
    @IBOutlet weak var labM0: UILabel!
    @IBOutlet weak var labM1: UILabel!
    @IBOutlet weak var labM2: UILabel!

    @IBOutlet weak var labR0: UILabel!
    @IBOutlet weak var labR1: UILabel!
    @IBOutlet weak var labR2: UILabel!

    @IBOutlet weak var labMTot: UILabel!
    @IBOutlet weak var labRTot: UILabel!
    
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    
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
        labSdate.text = dictItem["up_date"] as? String

    }
    
}