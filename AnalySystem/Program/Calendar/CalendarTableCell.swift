//
// UITableViewCell
//

import UIKit

/**
 * 集團全球行事曆, TableView Cell
 */
class CalendarTableCell: UITableViewCell {
    @IBOutlet weak var labCountry: UILabel!
    @IBOutlet weak var labTitle: UILabel!
    
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
        labCountry.text = dictItem["country"] as? String
        labTitle.text = dictItem["title"] as? String
    }
    
}