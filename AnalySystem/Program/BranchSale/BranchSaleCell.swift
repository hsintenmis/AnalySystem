//
// UITableViewCell
//

import Foundation
import UIKit

/**
 * 即時業績查詢 TableView Cell
 */
class BranchSaleCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    
    @IBOutlet weak var labBranch: UILabel!
    @IBOutlet weak var labNameDD: UILabel!
    @IBOutlet weak var labNameMM: UILabel!
    @IBOutlet weak var labNameYY: UILabel!
    
    @IBOutlet weak var DD_NT: UILabel!
    @IBOutlet weak var DD_ORG: UILabel!
    @IBOutlet weak var DD_NT_r: UILabel!
    
    @IBOutlet weak var MM_NT: UILabel!
    @IBOutlet weak var MM_ORG: UILabel!
    @IBOutlet weak var MM_NT_r: UILabel!
    
    @IBOutlet weak var YY_NT: UILabel!
    @IBOutlet weak var YY_ORG: UILabel!
    @IBOutlet weak var YY_NT_r: UILabel!
    
    private var pubClass = PubClass()
    private var aryFiledKey = ["DD_NT", "DD_ORG", "DD_NT_r",
                               "MM_NT", "MM_ORG", "MM_NT_r",
                               "YY_NT", "YY_ORG", "YY_NT_r"]
    private var dictField: Dictionary<String, UILabel> = [:]
    
    /**
     * Cell Load
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dictField["DD_NT"] = DD_NT
        dictField["DD_ORG"] = DD_ORG
        dictField["DD_NT_r"] = DD_NT_r
        dictField["MM_NT"] = MM_NT
        dictField["MM_ORG"] = MM_ORG
        dictField["MM_NT_r"] = MM_NT_r
        dictField["YY_NT"] = YY_NT
        dictField["YY_ORG"] = YY_ORG
        dictField["YY_NT_r"] = YY_NT_r
    }
    
    /**
     * 初始與設定 Cell
     */
    func initView(dictItem: Dictionary<String, AnyObject>!) {
        var strBranch = dictItem["branch"] as! String
        
        var bolNoData = true
        for strField in aryFiledKey {
            var strPrice = "--"
            if let strTmp = dictItem[strField] as? String {
                strPrice = strTmp
                bolNoData = false
            }
            
            dictField[strField]!.text = pubClass.fmtDelPoint(strPrice, bolUnit: dictItem["isUnit"] as! Bool)
        }
        
        // 判別是否為'加總' 資料
        if (!(dictItem["isSumData"] as! Bool)) {
            let strFrontCode = (strBranch == "all") ? "countryname_" : ("branch" + strBranch + "_")
            strBranch = pubClass.getLang(strFrontCode + (dictItem["office"] as! String))
            
            labBranch.text = strBranch + ((bolNoData) ? " " + pubClass.getLang("branchsalenodatamsg") : "")
            labBranch.hidden = false
        }
        else {
            labBranch.hidden = true
        }
 
    }
    
}