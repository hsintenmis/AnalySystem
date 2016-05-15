//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 區域代理排行 TableView Cell
 */
class AreaSaleCell: UITableViewCell {
    @IBOutlet weak var labRank: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labAreaname: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labOffice: UILabel!
    @IBOutlet weak var labPercent: UILabel!
    @IBOutlet weak var labYYSale: UILabel!
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labMMSale: UILabel!
    
    @IBOutlet weak var viewTitle: UIView!
    
    private var pubClass = PubClass()
    
    /**
     * Cell Load
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewTitle.layer.cornerRadius = 5.0
    }
    
    /**
     * 初始與設定 Cell
     */
    func initView(dictItem: Dictionary<String, AnyObject>!) {
        labRank.text = dictItem["rank"] as? String
        labName.text = dictItem["description"] as? String
        labAreaname.text = dictItem["areaname"] as? String
        labSdate.text = dictItem["begin_date"] as? String
        labOffice.text = dictItem["office"] as? String
        labPercent.text = dictItem["percent"] as? String
        labYYSale.text = dictItem["yearareasales"] as? String

        // 業績列表轉文字
        var strMM = pubClass.getLang("nosalethisyear") + "\n"
        var strSale = ""
        
        if let aryTmp = dictItem["month12"] as? Array<Dictionary<String, String>> {
            strMM = ""
            for dictTmp in aryTmp  {
                strMM += dictTmp["s_yymm"]! + "\n"
                strSale += pubClass.fmtDelPoint(dictTmp["areasales"]!, bolUnit: false)  + "\n"
            }
        }
        
        labMM.text = strMM
        labMMSale.text = strSale
    }
    
}