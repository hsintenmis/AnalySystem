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
    
    @IBOutlet var labGrpYYMM: [UILabel]!
    
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
        labSdate.text = dictItem["sdate"] as? String
        labName.text = dictItem["name"] as? String
        labDegree.text = dictItem["degree"] as? String
        
        let aryLab_M = [labM0, labM1, labM2]
        let aryLab_R = [labR0, labR1, labR2]
        let aryYYMM = dictItem["season"] as! Array<String>
        
        for loopi in (0..<3) {
            let str_i = String(loopi)
            let flt_R = dictItem["R" + str_i] as! Float32
            
            aryLab_M[loopi].text = pubClass.fmtDelPoint(String(dictItem["M" + str_i]!), bolUnit: true)
            aryLab_R[loopi].text = pubClass.fmtDelPoint(String(flt_R), bolUnit: true)
            
            labGrpYYMM[loopi].text = aryYYMM[loopi]
            
            if (flt_R > 0) {
                aryLab_M[loopi].textColor = pubClass.ColorHEX(myColor.GreenDark.rawValue)
            } else {
                aryLab_M[loopi].textColor = pubClass.ColorHEX(myColor.RedDark.rawValue)
            }
        }
        
        labMTot.text = pubClass.fmtDelPoint(String(dictItem["tot_M"]!), bolUnit: true)
        labRTot.text = pubClass.fmtDelPoint(String(dictItem["tot_R"]!), bolUnit: true)
        
        if ((dictItem["tot_R"] as! Float32) > 0) {
            labMTot.textColor = pubClass.ColorHEX(myColor.GreenDark.rawValue)
        } else {
            labMTot.textColor = pubClass.ColorHEX(myColor.RedDark.rawValue)
        }

    }
    
}