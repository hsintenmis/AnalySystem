//
// UIPickerView
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
    func doneSelect(strCountry: String, mField: UITextField)
}

/**
 * UIPickerView 公用程式，國別選擇
 */
class PickerCountry: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, KBNavyBarDelegate {
    
    // delegate
    var delegate = PickerCountryDelegate?()
    
    // property 設定
    private var pubClass  =  PubClass()
    private var mKBNavyBar = KBNavyBar()
    private var mPKView = UIPickerView()
    private var mPickField: UITextField!
    
    private var aryListData: Array<String>! // 選單 list array data
    private var strSelCountry: String?  // 選擇的國家
    
    /**
     * PickerNumber init<br>
     */
    init(withUIField mField: UITextField, aryCountry: Array<String>!, defCountry: String?, strTitle: String) {
        super.init()
        
        // 參數設定
        mPKView.delegate = self
        mPickField = mField
        aryListData = aryCountry
        
        // 設定預設值
        if (defCountry != nil) {
            setDefVal(defCountry!)
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗', 輸入鍵盤，樣式
        mPickField.inputView = mPKView
        mKBNavyBar.delegate = self
        mPickField.inputAccessoryView = mKBNavyBar.getKBBar(strTitle)
    }
    
    /**
     * 設定預設值
     */
    func setDefVal(strVal: String) {
        for i in (0..<aryListData.count) {
            if (aryListData[i] == strVal) {
                mPKView.selectRow(i, inComponent: 0, animated: false)
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
        return aryListData.count
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pubClass.getLang("countryname_" + aryListData[row])
    }
    
    /**
     * #mark: UIPickerViewDelegate, 各個下拉選單，點取執行相關程序
     */
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strSelCountry = aryListData[row]
    }
    
    /**
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'done'
     */
    func KBBarDone() {
        mPickField.resignFirstResponder()
        delegate?.doneSelect(strSelCountry!, mField: mPickField)
    }
    
    /**
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'cancel'
     */
    func KBBarCancel() {
        mPickField.resignFirstResponder()
    }
    
}