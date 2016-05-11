//
// UIPickerView, 直接 VC 處理
//

import Foundation
import UIKit

/**
 * protocol, 年月區間選擇 Delegate
 */
protocol PickerYMPeriodDelegate {
    /**
     * Pickr view 虛擬鍵盤, 點取'完成' btn, 回傳選擇的起始 position
     */
    func doneDateSelect(aryPosition: Array<Int>)
}

/**
 * UIPickerView 公用程式，年月區間選擇
 */
class PickerYMPeriod: UIViewController {
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var pickView0: UIPickerView!
    @IBOutlet weak var pickView1: UIPickerView!

    // delegate
    var delegate = PickerYMPeriodDelegate?()
    
    // property 設定
    private var pubClass = PubClass()
    private var aryPickView: Array<UIPickerView>!
    
    // public, parent 設定
    var aryYYMM: Array<String>! // 選單 list array data
    var aryPosition = [0, 0] // 資料開始/結束 position
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aryPickView = [pickView0, pickView1]
        setDefVal(aryPosition)
    }
    
    /**
     * 設定下拉資料的預設值
     */
    func setDefVal(aryPosition: Array<Int>) {
        for loopi in (0..<2) {
            (aryPickView[loopi]).selectRow(aryPosition[loopi], inComponent: 0, animated: false)
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
        return aryYYMM.count
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        return pubClass.subStr(aryYYMM[row], strFrom: 0, strEnd: 4) + " " + pubClass.getLang("mm_" + pubClass.subStr(aryYYMM[row], strFrom: 4, strEnd: 6))
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，點取執行相關程序
     */
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        aryPosition[pickerView.tag] = row
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
        self.dismissViewControllerAnimated(true, completion: {self.delegate?.doneDateSelect(self.aryPosition)})
    }
    
}