//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 經銷商業績排行, 本人/下線 積分查詢, TableView Cell
 */
class TopRankDetailCell: UITableViewCell {
    
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDegree: UILabel!
    @IBOutlet weak var labPV: UILabel!
    @IBOutlet weak var labInvoice: UILabel!
    
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

        labName.text = dictItem["cus_name"] as? String
        labDegree.text = dictItem["degree"] as? String
        labPV.text = dictItem["pv"] as? String
        
        // 處理 invoice 轉文字
        let aryInvo = dictItem["invoice"] as! Array<Dictionary<String, AnyObject>>
        var strInvo = ""
        
        for dictTmp in aryInvo {
            let strPv = dictTmp["pv"] as! String
            let strDate = dictTmp["sdate"] as! String
            strInvo += strDate + ", " + "pv: " + strPv + "\n"
        }
        
        labInvoice.text = strInvo
    }
    
}