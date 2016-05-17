//
// CollectView
//

import UIKit

/**
 * protocol, TopRankColtView Delegate
 */
protocol CountryColtViewDelegate {
    /**
     * collectView 的 Cell 點取, 回傳 country code
     */
    func CountrySelectDone(countryCode: String)
}

/**
 * 國別選擇 CollectView
 */
class CountryColtView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    // delegate
    var delgCountryColtVC = CountryColtViewDelegate?()
    
    // common property
    private var pubClass = PubClass()
    private var aryAllData: Array<String> = []
    
    // 其他參數
    private var currCountry = ""
    
    
    /**
     * init data
     */
    func initData(aryData: Array<String>) {
        dataSource = self
        delegate = self
        
        aryAllData = aryData
        currCountry = aryAllData[0]
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定列數 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (aryAllData.count < 1) ? 0 : 1
    }
    
    /**
     * #mark: CollectionView, 檢測項目, 設定每列 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryAllData.count
    }
    
    /**
     * #mark, CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let mCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellCountryColt", forIndexPath: indexPath) as! CountryColtCell
        let strCountry = aryAllData[indexPath.row]
        
        mCell.labName.text = pubClass.getLang("countryname_" + strCountry)
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        
        var strColor = myColor.Sliver.rawValue
        
        if (strCountry == currCountry) {
            strColor = myColor.Blue.rawValue
        }
        
        mCell.backgroundColor = pubClass.ColorHEX(strColor)
        
        return mCell
    }
    
    /**
     * #mark, CollectionView, Cell 點取
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        currCountry = aryAllData[indexPath.row]
        
        // 通知 parent 全部資料需重整
        delgCountryColtVC?.CountrySelectDone(currCountry)
        self.reloadData()
        
        return
    }
    
    
}