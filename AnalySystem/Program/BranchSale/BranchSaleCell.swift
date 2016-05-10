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
        let strBranch = dictItem["branch"] as! String
        let strFontCode = (strBranch == "all") ? "countryname_" : ("branch" + strBranch + "_")
        
        labBranch.text = pubClass.getLang(strFontCode + (dictItem["office"] as! String))
        
        for strField in aryFiledKey {
            let strPrice = dictItem[strField] as! String
            dictField[strField]!.text = fmtDelPoint(strPrice, bolUnit: dictItem["isUnit"] as! Bool)
        }
    }
    
    /**
     * 去除小數點，格式化為貨幣顯示形式, ex. 12,345,678
     * @parm bolUnit: 顯示為萬元
     */
    private func fmtDelPoint(strPrice: String!, bolUnit: Bool)->String {
        var price = Float(strPrice)
        var strRS = "0"
        
        if (bolUnit == true) {
            price = (price! / 10000)
        }
        
        let objFMT = NSNumberFormatter()
        objFMT.numberStyle = .DecimalStyle
        objFMT.roundingMode = NSNumberFormatterRoundingMode.RoundDown
        objFMT.maximumFractionDigits = 0
        
        strRS = objFMT.stringFromNumber(price!)!
        
        return strRS
    }
    
}