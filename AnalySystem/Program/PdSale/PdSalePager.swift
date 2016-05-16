//
// PageViewController
// HTTP 資料取得資料由本 class 處理
//

import Foundation
import UIKit

/**
 * protocol, PagerView 相關
 */
protocol PdSalePagerDelegate {
    /**
     * page 滑動完成, 傳送 position, 需要顯示的 YYMM
     */
    func PageTransFinish(position: Int, totNums: Int, YYMM: String?)
}

/**
 * 會員主選單下的 資料列表, 使用 pager
 */
class PdSalePager: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // delegate, PagerView 相關
    var delgPager = PdSalePagerDelegate?()
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 設定
    var currCountryCode: String!  // 目前選擇的國別 code
    
    // 各個 Pager Table 需要的 datasource
    private var dictAllData: Dictionary<String, AnyObject>!
    private var aryPages: Array<UIViewController> = []  // 全部 page 的 array
    private var indexPages = -1;  // 目前已滑動完成 page 的 position
    private var indexNextPages = 1;
    
    // 其他參數
    private var aryYYMM: Array<String>!  // YYMM array
    
    /**
     * View DidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIPageViewController 的 delegate
        self.delegate = self
        self.dataSource = self
    }
    
    /**
     * viewDidAppear
     */
    override func viewDidAppear(animated: Bool) {
        reConnHTTP()
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 初始與顯示第一個頁面
        self.makePages()
        self.moveToPage(0)
    }
    
    /**
     * public, HTTP 重新連線取得資料
     */
    func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "pdsale"
        mParam["act"] = "pdsale_getdata"
        mParam["country"] = currCountryCode

        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            self.dictAllData = dictData
            self.chkHaveData()
        })
    }

    /**
     * 產生各個 page 頁面，加到 'aryPages'
     */
    private func makePages() {
        aryPages = []
        aryYYMM = []
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        // 取得指定國別全部的 array data
        var aryAllData: Array<AnyObject> = []
        if let aryTmp = dictAllData["data"] as? Array<AnyObject> {
            if (aryTmp.count > 0) {
                aryAllData = aryTmp
            }
        }
        
        if (aryAllData.count < 1) {
            let mVC = storyboard.instantiateViewControllerWithIdentifier("PageNoData")
            aryPages.append(mVC)
            
            return
        }
        
        
        // 依序產生 pager 需要的頁面資料
        let numsPage = aryAllData.count
        let dictPdName = dictAllData["pd"] as! Dictionary<String, String>
        
        for loopi in (0..<numsPage) {
            let mVC: PdSaleTable = storyboard.instantiateViewControllerWithIdentifier("PdSaleTable") as! PdSaleTable
            
            mVC.dictAllData = aryAllData[loopi] as! Dictionary<String, AnyObject>
            mVC.dictPdName = dictPdName
            aryPages.append(mVC)
            
            // 產生 YYMM array
            let intYYMM = aryAllData[loopi]["YYMM"] as! Int
            aryYYMM.append(String(intYYMM))
        }
    }
    
    /**
     * public
     * 根據代入的 position 滑動到指定的頁面
     */
    func moveToPage(position: Int) {
        // 檢查 position 是否合法
        var newPosition = position
        
        if (position < 0) {
            newPosition = 0
        }
        else if (position >= (aryPages.count - 1)) {
            newPosition = (aryPages.count - 1)
        }
        
        // 判別 左/右 滑動
        var mDirect = UIPageViewControllerNavigationDirection.Forward
        if (indexPages > newPosition) {
            mDirect = UIPageViewControllerNavigationDirection.Reverse
        }

        //let mDirect = (position == 0) ? UIPageViewControllerNavigationDirection.Reverse : UIPageViewControllerNavigationDirection.Forward
        
        indexPages = newPosition
        setViewControllers([aryPages[newPosition]], direction: mDirect, animated: true, completion: nil)
        
        // parent class 執行相關程序
        if (aryYYMM.count > 0) {
            delgPager?.PageTransFinish(newPosition, totNums:aryYYMM.count, YYMM: aryYYMM[newPosition])
        } else {
            // parent class 執行相關程序
            delgPager?.PageTransFinish(-1, totNums: 0, YYMM: nil)
        }
    }
    
    /**
     * #mark: UIPageViewController delegate
     * page 前一個頁面
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = aryPages.indexOf(viewController)!
        
        //let previousIndex = abs((currentIndex - 1) % pages.count)
        let previousIndex = (currentIndex - 1)
        indexPages = previousIndex
        
        if (previousIndex < 0) {
            indexPages = 0
            return nil
        }
        
        return aryPages[previousIndex]
    }
    
    /**
     * #mark: UIPageViewController delegate
     * page 下個頁面
     */
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = aryPages.indexOf(viewController)!
        
        //let nextIndex = abs((currentIndex + 1) % pages.count)
        let nextIndex = currentIndex + 1
        indexPages = nextIndex
        
        if (nextIndex == aryPages.count) {
            indexPages = currentIndex
            return nil
        }
        
        return aryPages[nextIndex]
    }
    
    /**
     * #mark: UIPageViewController delegate
     * page 總頁數
     */
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        //return (aryPages.count == 5) ? 0 : aryPages.count
        return aryPages.count
    }
    
    /**
     * #mark: UIPageViewController delegate
     * 回傳選擇頁面的 position
     */
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.indexPages
    }
    
    /**
     * #mark: UIPageViewController delegate
     * Called after a gesture-driven transition completes.
     * 滑動完成時
     */
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // 滑動完成時, 取得目前頁面 position
        if(completed){
            self.indexPages = self.indexNextPages;
            
            // parent class 執行相關程序
            delgPager?.PageTransFinish(self.indexNextPages, totNums:aryYYMM.count, YYMM: aryYYMM[self.indexNextPages])
            
            return
        }
        
        self.indexNextPages = 0;
    }
    
    /**
     * #mark: UIPageViewController delegate
     * Called before a gesture-driven transition begins.
     * 滑動開始時
     */
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
        let controller = pendingViewControllers.first
        self.indexNextPages = aryPages.indexOf(controller!)!
    }
    
}