//
// WatchTypeSelectTableViewController.swift
// MBTLink
//
// ウォッチ種類選択
//

import UIKit

class WatchTypeSelectTableViewController: UITableViewController {
    // MARK: - Public変数
    /// LANCEBAND2,3管理辞書
    public var WatchManageDic : [String : WatchManageService]!
    /// CRPSmartBnd管理辞書
    public var CRPSmartBandManageDic : [String : CRPSmartBandManageService]!
    
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: ( WatchTypeSelectTableViewController.self)).split(separator: "-")[0])
    ///ログメッセージ
    private var logMessage = ""
    /// データ通信サービス
    private let dcService = DataCommunicationService()
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        navigationItem.backBarButtonItem = backbutton
        
        // ナビゲーションタイトル
        
        let navbarTitle = UILabel()
        navbarTitle.text = StringsConst.Wearable_Device_Selection
            navbarTitle.font = UIFont.boldSystemFont(ofSize: 17)
            navbarTitle.minimumScaleFactor = 0.5
            navbarTitle.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = navbarTitle
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CommonUtil.Print(className: self.className, message: "viewWillAppear表示")
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }
    /// 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 自身のviewControllerを削除
        navigationController?.viewControllers.removeAll(where: { $0 === self })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
    }

    // MARK: - Table view イベント関連
    /// Viewのセクション数を返却
    override func numberOfSections(in tableView: UITableView) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 1
    }
    
    /// Viewの各セクションの行数を返却
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 2
    }
    
    /// ヘッダーの高さを設定
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //システムログ作成、送信
        //LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "")
        return 60
    }
    
    /// 各ボタン押下時遷移先設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case CommonConst.Segue.WatchSetting:
            // LANCEBAND
            guard let destination = segue.destination as? WatchSettingViewController else {
                fatalError("Failed to prepare WatchSettingViewController.")
            }
            // ウォッチ管理辞書
            destination.WatchManageDic = self.WatchManageDic
            // ウォッチ管理サービス
            let watchManage = WatchManageService()
            destination.WatchManageService = watchManage
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "WatchSettingViewController")
            break
        case CommonConst.Segue.WatchSettingCRPSmartBand:
            // CRPSmartBand
            guard let destination = segue.destination as? WatchSettingCRPSmartBandViewController else {
                fatalError("Failed to prepare WatchSettingCRPSmartBandViewController.")
            }
            // ウォッチ管理辞書
            destination.WatchManageDic = self.CRPSmartBandManageDic
            // ウォッチ管理サービス
            let watchManage = CRPSmartBandManageService()
            destination.WatchManageService = watchManage
            //システムログ作成、送信
            LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: self.className , functionName: #function , message: "WatchSettingCRPSmartBandViewController")
            break
        default:
            break
        }
    }
}
