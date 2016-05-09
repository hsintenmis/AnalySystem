//
// App 進入頁面
//

import UIKit

/**
 * 本專案首頁，USER登入頁面
 */
class MainLogin: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var swchLang: UISegmentedControl!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var labVer: UILabel!
    @IBOutlet weak var edAcc: UITextField!
    @IBOutlet weak var edPsd: UITextField!
    @IBOutlet weak var swchSave: UISwitch!
    @IBOutlet weak var labRemember: UILabel!
    
    // common property
    private var pubClass = PubClass()
    
    private var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    /**
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 參數與頁面 field 設定
        dictPref = pubClass.getPrefData()
        btnLogin.layer.cornerRadius = 5
        
        // 語系 switch 預設
        let langCode = pubClass.getPrefData("lang") as! String
        pubClass.setAppDelgVal("V_LANGCODE", withVal: langCode)
        
        for loopi in (0..<pubClass.aryLangCode.count) {
            if (langCode == pubClass.aryLangCode[loopi]) {
                swchLang.selectedSegmentIndex = loopi
                
                break
            }
        }
        
        // 設定頁面語系
        self.setPageLang()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        edAcc.text = dictPref["acc"] as? String
        edPsd.text = dictPref["psd"] as? String
        swchSave.setOn((dictPref["issave"] as! Bool), animated: false)
    }

    /**
     * 設定頁面顯示文字
     */
    private func setPageLang() {
        labTitle.text = pubClass.getLang("app_name")
        labVer.text = pubClass.getLang("version") + ":" + (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String)
    }
    
    /**
     * user 登入資料送出, HTTP 連線檢查與初始
     */
    func StartHTTPConn() {
        // acc, psd 檢查
        if ((edAcc.text?.isEmpty) == true || (edPsd.text?.isEmpty) == true) {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_accpsd"))
            
            return
        }
        
        // 連線 HTTP post/get 參數
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = edAcc.text?.uppercaseString;
        dictParm["psd"] = edPsd.text;
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            dispatch_async(dispatch_get_main_queue(), {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang(dictRS["msg"] as? String))
            })
            
            return
        }
        
        // 解析資料, 資料存入 'Prefer'
        let dictData = dictRS["data"]!["content"]!
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        
        if (swchSave.on == true) {
            mPref.setObject(edAcc.text, forKey: "acc")
            mPref.setObject(edPsd.text, forKey: "psd")
            mPref.setObject(true, forKey: "issave")
        }
        else {
            mPref.setObject("", forKey: "acc")
            mPref.setObject("", forKey: "psd")
            mPref.setObject(false, forKey: "issave")
        }
        
        mPref.synchronize()
        
        // 設定全域變數, 傳遞 child data dict array
        pubClass.setAppDelgVal("V_USRACC", withVal: edAcc.text!)
        pubClass.setAppDelgVal("V_USRPSD", withVal: edPsd.text!)
        
        var dicTranData: Dictionary<String, AnyObject> = [:]
        dicTranData["name"] = dictRS["data"]!["name"]
        
        if let strPriv = dictData!["priv"] as? String {
            let aryPriv = strPriv.componentsSeparatedByString(",")
            dicTranData["priv"] = aryPriv
            pubClass.setAppDelgVal("V_PRIV", withVal: aryPriv)
        } else {
            self.pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"))
            
            return
        }
        
        // 跳轉至指定的名稱的Segue頁面, 傳遞參數

        self.performSegueWithIdentifier("MainMenu", sender: dicTranData)
    }

    /**
     * #mark: TextView Delegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == edAcc {
            edPsd.becomeFirstResponder();
            return true
        }
        
        if textField == edPsd {
            edPsd.resignFirstResponder()
            StartHTTPConn() // 執行 http 連線程序
            return true
        }
        
        return true
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "MainMenu") {
            let mVC = segue.destinationViewController as! MainMenu
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
        return
    }
    
    /**
     * act 語系改變, prefer data 'langCode' 更新
     * swicth lang: Base, zh-Hans, zh-Hant
     */
    @IBAction func actSegmLang(sender: UISegmentedControl) {
        
        let aryLang = pubClass.aryLangCode
        
        // 資料存入 'Prefer'
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        let langCode = aryLang[sender.selectedSegmentIndex]
        mPref.setObject(langCode, forKey: "lang")
        mPref.synchronize()
        
        pubClass.setAppDelgVal("V_LANGCODE", withVal: langCode)
        self.setPageLang()
    }
    
    /**
     * act, btn '登入'
     */
    @IBAction func actLogin(sender: UIButton) {
        self.StartHTTPConn()
    }
    
    /**
     * 螢幕上方狀態列隱藏
     */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}