//
// ContainerView
// CollectionView 直接獨立一個 class 處理
//

import UIKit

/**
 * 商品銷售排行, 使用 Pager 處理
 */
class PdSale: UIViewController, CountryColtViewDelegate, PdSalePagerDelegate {
    
    // @IBOutlet
    @IBOutlet weak var colviewCountry: CountryColtView!
    @IBOutlet weak var labYYMM: UILabel!
    @IBOutlet weak var btnPre: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    // common property
    private var pubClass = PubClass()
    
    // 其他參數
    private var mPager: PdSalePager!
    private var aryPriv: Array<String>! // user 國別權限 array
    private var currCountryCode = ""  // 目前選擇的國別 code
    private var currPagerPosition = 0
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnPre.hidden = true
        btnNext.hidden = true
        
        // 實體化與設定 collectView 內容
        initPrivCountry()
        colviewCountry.delgCountryColtVC = self
        colviewCountry.initData(aryPriv)
        
        // 設定頁面語系
        self.setPageLang()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {

    }
    
    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        
    }
    
    /**
     * 取得國別權限 ary, 設定初始預設國別
     */
    private func initPrivCountry() {
        aryPriv = pubClass.getAppDelgVal("V_PRIV") as! Array<String>
        currCountryCode = aryPriv[0]
    }
    
    /**
     * #mark: CountryColtView Delegate, 國別選擇 collectView 點取 Cell
     */
    func CountrySelectDone(countryCode: String) {
        mPager.currCountryCode = countryCode
        mPager.reConnHTTP()
    }
    
    /**
     * #mark: PdSalePager Delegate, pager 頁面滑動完成時
     */
    func PageTransFinish(position: Int, totNums: Int, YYMM: String?) {
        currPagerPosition = position
        btnPre.hidden = false
        btnNext.hidden = false
        
        if (YYMM == nil) {
            labYYMM.text = "--"
            btnPre.hidden = true
            btnNext.hidden = true
            
            return
        }
        
        labYYMM.text = pubClass.subStr(YYMM!, strFrom: 0, strEnd: 4) + " " + pubClass.getLang("mm_" + pubClass.subStr(YYMM!, strFrom: 4, strEnd: 6))
        
        if (position == 0) {
            btnPre.hidden = true
        }
        
        if (position == (totNums - 1)) {
            btnNext.hidden = true
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "PdSalePager") {
            initPrivCountry()
            
            mPager = segue.destinationViewController as! PdSalePager
            mPager.currCountryCode = currCountryCode
            mPager.delgPager = self
            
            return
        }
        
        return
    }
    
    /**
     * act, btn '前月'
     */
    @IBAction func actPre(sender: UIButton) {
        mPager.moveToPage(currPagerPosition - 1)
    }
    
    /**
     * act, btn '次月'
     */
    @IBAction func actNext(sender: UIButton) {
        mPager.moveToPage(currPagerPosition + 1)
    }
    
    
    /**
     * act, btn '主選單'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}