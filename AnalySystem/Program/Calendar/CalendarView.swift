//
// CollectionView, Calendar 設定
//

import UIKit

/**
 * protocol, PubClass Delegate
 */
@objc protocol CalendarViewDelegate {
    /**
     * 月曆點取 日期/前月次月, 資料變動通知 parent 處理
     */
    func CalendarDataChange(dictYMD: Dictionary<String, String>!)
}

/**
 * Calendar 公用 class, 使用 UICollectionView 產生
 */
class CalendarView: UIViewController {
    // delegate
    var delgCalendar = CalendarViewDelegate?()
    
    // 固定參數
    let D_TIMEZONE: Int = 8 // 時區 +8
    
    // @IBOutlet
    @IBOutlet var btnGrpArrow: [UIButton]!  // 前月/次月
    @IBOutlet var grpWeekName: [UILabel]!
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labYY: UILabel!
    @IBOutlet weak var coltCalendar: UICollectionView!
    
    // common property
    private var pubClass = PubClass()
    
    // calendar 相關參數
    private var aryFixWeek = ["Sun", "Mon","Tue","Wed","Thu","Fri","Sat"]
    private var mNSDate = NSDate()
    private var mCalendar: NSCalendar!
    private var mCompnts: NSDateComponents!
    
    // 本月曆的起始 YYMM, 目前的 YMD, ex. YY='2016', MM='01', DD='03'
    private var currYMD: Dictionary<String, String> = [:]
    private var firstYYMM = "201501"
    private var lastYYMM = "202512"
    
    // 指定月份內每個日期 Block 資料, 7x6=42 個 Block 資料
    private var aryAllBlock: Array<Array<Dictionary<String, AnyObject>>> = []
    
    // 有資料的全部月份 dict data, 目前月份日期有資料的 dict data
    private var allDictDataMM: Dictionary<String, AnyObject> = [:]
    private var currDictDataMM: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var strToday: String!  // 僅設定一次, 點取 '今日' btn 使用
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 相關參數初始
        mCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        mCompnts = mCalendar!.components(NSCalendarUnit.Month, fromDate: mNSDate)

        // 預設今天日期
        strToday = pubClass.subStr(pubClass.getDevToday(), strFrom: 0, strEnd: 8)
        currYMD["YY"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 4)
        currYMD["MM"] = pubClass.subStr(strToday, strFrom: 4, strEnd: 6)
        currYMD["DD"] = pubClass.subStr(strToday, strFrom: 6, strEnd: 8)
        
        // 產生月曆每個 'Block' 的資料
        resetCurrDictDataMM()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        
    }
    
    /**
     * public, 由 parent 執行初始 calendar
     *
     * @YMD: 目前的 YMD, dict array, val =String
     * @allDataMM: 全部月份 日期有資料的 dict data, key前置字元=> 'key'
     */
    func initCalendar(YMD: Dictionary<String, String>!, allDataMM: Dictionary<String, AnyObject>, aryBeginEndYM: Array<String>!) {
        
        currYMD["YY"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 4)
        currYMD["MM"] = pubClass.subStr(strToday, strFrom: 4, strEnd: 6)
        currYMD["DD"] = pubClass.subStr(strToday, strFrom: 6, strEnd: 8)
        strToday = currYMD["YY"]! + currYMD["MM"]! + currYMD["DD"]!
        
        currYMD = YMD
        firstYYMM = aryBeginEndYM[0]
        lastYYMM = aryBeginEndYM[1]
        
        allDictDataMM = allDataMM
        
        // 重新取得目前月份日期有資料的 dict data, 月曆資料重整
        resetCurrDictDataMM()
    }
    
    /**
     * 重新取得目前月份日期有資料的 dict data
     * 點取 '前月/次月', '今日', 月曆資料內容改變，
     */
    private func resetCurrDictDataMM() {
        let strKey = "key" + currYMD["YY"]! + currYMD["MM"]!
        currDictDataMM = [:]
        
        if let aryTmp = allDictDataMM[strKey] as? Array<Dictionary<String, AnyObject>> {
            
            for dictTmp in aryTmp {
                let strDD = "dd" + String(Int(dictTmp["DD"] as! String)!)
                currDictDataMM[strDD] = dictTmp["data"] as! Dictionary<String, AnyObject>
            }
        }
        
        setCalendarData()
    }
    
    /**
     * 產生月曆每個 'Block' 的資料, 7x6=42 個 Block 資料
     */
    func setCalendarData() {
        aryAllBlock = []
        
        // 初始 NSDate 相關參數
        mCompnts.year = Int(currYMD["YY"]!)!
        mCompnts.month = Int(currYMD["MM"]!)!
        mCompnts.hour = D_TIMEZONE;
        mCompnts.minute = 0;
        mCompnts.second = 1;
        
        // 指定月份的第一天，最後一天，格式為 NSDate
        mCompnts.day = 1
        let firstDateOfMonth: NSDate = mCalendar!.dateFromComponents(mCompnts)!
        
        // 最後一天
        mCompnts.month += 1
        mCompnts.day = 0
        let lastDateOfMonth: NSDate = mCalendar!.dateFromComponents(mCompnts)!
        
        // ex. 取得 10月01日 是星期幾, 最後一天是幾號
        let firstWeekName: String = pubClass.subStr(getFormatYMD(firstDateOfMonth), strFrom: 8, strEnd: 11)
        let lastMonthDay: Int = Int(pubClass.subStr(getFormatYMD(lastDateOfMonth), strFrom: 6, strEnd: 8))!
        
        /* 開始產生月曆每個 'Block' 的資料 */
        
        // 目前處理 aryAllBlock 的 '日期'
        var currDay: Int = 1;
        
        // 月曆 第一個 資料列
        var arySect: Array<Dictionary<String, AnyObject>> = []
        var dictBlock: Dictionary<String, AnyObject>!
        
        var strDayKey = ""  // ex. 1日 => 'dd1'
        var isStartSet = false  // 是否開始設定資料 flag
        
        for loopi in (0..<7) {
            dictBlock = [:]
            dictBlock["data"] = nil
            
            // 設定 block 從第幾個開始有資料
            if (firstWeekName == aryFixWeek[loopi] && !isStartSet) {
                isStartSet = true
            }
            
            if (!isStartSet) {
                dictBlock["txtDay"] = ""
                arySect.append(dictBlock)
                
                continue
            }
            
            // 指定日期是否有資料
            strDayKey = "dd" + String(currDay)
            if let tmpData = currDictDataMM[strDayKey] {
                dictBlock["data"] = tmpData
            }
            
            // 其他欄位設定，dict data 加入 '列' array
            dictBlock["txtDay"] = String(currDay)
            currDay += 1
            arySect.append(dictBlock)
        }
        
        aryAllBlock.append(arySect)
        
        // 其他 sect 列設定, 2~6 列
        for _ in (1..<6) {
            arySect = []
            
            // 指定的 sect 列, 設定「星期幾」的資料
            for _ in (0..<7) {
                dictBlock = [:]
                dictBlock["data"] = nil
                
                if (currDay <= lastMonthDay) {
                    dictBlock["txtDay"] = String(currDay)
                    
                    // 指定日期是否有資料
                    strDayKey = "dd" + String(currDay)
                    if let tmpData = currDictDataMM[strDayKey] {
                        dictBlock["data"] = tmpData
                    }
                }
                else {
                    dictBlock["txtDay"] = ""
                }
                
                arySect.append(dictBlock)
                currDay += 1
            }
            
            aryAllBlock.append(arySect)
        }
        
        // 初始與設定 VCview 內的 field
        initViewField()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        labYY.text = currYMD["YY"]
        labMM.text = pubClass.getLang("mm_" + currYMD["MM"]!)
        coltCalendar.reloadData()
        
        // 通知 parent 日期有變動
        delgCalendar?.CalendarDataChange(currYMD)
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (aryAllBlock.count > 0) ? 6 : 0
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (aryAllBlock.count > 0) ? 7 : 0
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (aryAllBlock.count < 1) {
            return UICollectionViewCell()
        }
        
        let mCell: CalendarCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellCalendar", forIndexPath: indexPath) as! CalendarCell
        
        let dictBlock: Dictionary<String, AnyObject> = aryAllBlock[indexPath.section][indexPath.row]
        let strDay = dictBlock["txtDay"] as! String
        
        // 樣式/外觀/顏色
        mCell.labDate.text = strDay
        mCell.labDate.layer.borderWidth = 1
        mCell.labDate.layer.cornerRadius = 25 / 2  // 日期文字的高度 storyboard 設定
        mCell.labDate.layer.borderColor = (pubClass.ColorHEX(myColor.White.rawValue)).CGColor
        mCell.labDate.layer.backgroundColor = (pubClass.ColorHEX(myColor.White.rawValue)).CGColor
        
        // 沒有日期資料
        if (strDay.characters.count < 1) {
            return mCell
        }
        
        // 有資料的日期
        if dictBlock["data"] != nil {
            mCell.labDate.layer.borderColor = (pubClass.ColorHEX(myColor.Green.rawValue)).CGColor
        }
        
        // 目前選擇的日期
        if (currYMD["DD"] == String(format: "%02d", Int(strDay)!)) {
            mCell.labDate.layer.borderColor = (pubClass.ColorHEX(myColor.Blue.rawValue)).CGColor
            mCell.labDate.layer.backgroundColor = (pubClass.ColorHEX(myColor.Blue.rawValue)).CGColor
        }
        
        return mCell
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 點取 Cell
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 取得點取的 txtDate 是否有文字, ex. '23'
        let dictBlock: Dictionary<String, AnyObject> = aryAllBlock[indexPath.section][indexPath.row]
        let strDay = dictBlock["txtDay"] as! String
        
        if (strDay == "") {
            return
        }
        
        // collection view 重整
        currYMD["DD"] = String(format: "%02d", Int(strDay)!)
        coltCalendar.reloadData()
        
        // 通知 parent 日期有變動
        delgCalendar?.CalendarDataChange(currYMD)
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, Cell width
     */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.bounds.size.width/7) - 1.0, height: (collectionView.bounds.size.height/6) - 0.5)
    }
    
    /**
     * pubcli, 點取 '今日'
     */
    func actToday() {
        currYMD["YY"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 4)
        currYMD["MM"] = pubClass.subStr(strToday, strFrom: 4, strEnd: 6)
        currYMD["DD"] = pubClass.subStr(strToday, strFrom: 6, strEnd: 8)
        
        self.resetCurrDictDataMM()
    }
    
    /**
     * act, 點取 前月/次月 button, tag0= 前月, tab1= 次月
     */
    @IBAction func actChangMM(sender: UIButton) {
        var YY: Int = Int(currYMD["YY"]!)!
        var MM: Int = Int(currYMD["MM"]!)!
        
        if (sender.tag == 1) {
            if (lastYYMM == (currYMD["YY"]! + currYMD["MM"]!)) {
                return
            }
            
            MM += 1
            if (MM > 12) {
                MM = 1; YY += 1;
            }
        }
        else {
            if (firstYYMM == (currYMD["YY"]! + currYMD["MM"]!)) {
                return
            }
            
            MM -= 1;
            if (MM < 1) {
                MM = 12; YY -= 1;
            }

        }
        
        currYMD["YY"] = String(YY)
        currYMD["MM"] = String(format:"%02d", MM)
        currYMD["DD"] = "01"
        
        self.resetCurrDictDataMM()
    }
    
    /**
     * 回傳格式化後的 日期/時間
     * http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
     *
     * 本 class 需要的格式回傳如: '20151031Wed' (YYYY MM DD Week)
     */
    func getFormatYMD(mDate: NSDate)->String {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd ccc HH:mm"
        dateFormatter.dateFormat = "yyyyMMddccc"
        
        // 顯示如 '20160201Mon', 星期名稱一定是'英文'
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return dateFormatter.stringFromDate(mDate)
    }
    
}