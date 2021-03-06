//
// UIPickerView, 直接 VC 處理
//

import Foundation
import UIKit

/**
 * protocol, 國別選擇 Delegate
 */
protocol PickerCountryDelegate {
    /**
     * Pickr view 虛擬鍵盤, 點取'完成' btn, 回傳選擇的 country code
     */
    func doneSelect(strCountry: String)
}

/**
 * UIPickerView 公用程式，國別選擇
 */
class PickerCountry: UIViewController {
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // delegate
    var delegate = PickerCountryDelegate?()
    
    // property 設定
    private var pubClass  =  PubClass()
    
    // public, parent 設定
    var aryCountry: Array<String>! // 選單 list array data
    var strSelCountry: String? // 選擇的國家
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定預設值
        if (strSelCountry != nil) {
            setDefVal(strSelCountry!)
        } else {
            strSelCountry = aryCountry[0]
        }
    }
    
    /**
     * 設定下拉資料的預設值
     */
    func setDefVal(strVal: String) {
        for i in (0..<aryCountry.count) {
            if (aryCountry[i] == strVal) {
                pickerView.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
    }
    
    /**
     * #mark: UIPickerViewDelegate, 有幾個 '下拉選單'
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，有幾筆資料
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryCountry.count
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pubClass.getLang("countryname_" + aryCountry[row])
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，點取執行相關程序
     */
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strSelCountry = aryCountry[row]
    }
    
    /**
     * act, btn 點取 '取消'
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    /**
     * act, btn 點取 '完成'
     */
    @IBAction func actDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {self.delegate?.doneSelect(self.strSelCountry!)})
        
    }
    
    
}