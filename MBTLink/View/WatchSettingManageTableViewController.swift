//
// WatchSettingManageTableViewController.swift
// ウォッチ設定管理TableView
//
// MBTLink
//

import UIKit

class WatchSettingManageTableViewController: UITableViewController {
    
    // MARK: - UI部品
    /// ウォッチ設定TableView
    @IBOutlet var watchSettingTableView: UITableView!
    
    // MARK: - Private変数
    /// ウォッチ設定管理ViewController
    private var watchSettingManageVc : WatchSettingManageViewController!
    /// セル選択インデックス
    private var cellSelectIndex : Int = 0

    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// viewが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ウォッチ設定管理ViewController
        self.watchSettingManageVc = (self.parent as! WatchSettingManageViewController)
    }
    
    /// セル選択時遷移先設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == CommonConst.Segue.WatchSetting{
            // ウォッチ設定画面
            guard let destination = segue.destination as? WatchSettingViewController else {
                fatalError("Failed to prepare WatchSettingViewController.")
            }

            // ウォッチ管理辞書
            destination.WatchManageDic = self.watchSettingManageVc.WatchManageDic
            // ウォッチ管理サービス
            destination.WatchManageService = Array(self.watchSettingManageVc.WatchManageDic.values)[self.cellSelectIndex]
        }
    }

    // MARK: - Table view イベント関連
    /// セクション数を返す
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /// セルの数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.watchSettingManageVc.WatchManageDic.count
    }
    
    /// 各セルを生成して返却します。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = Array(self.watchSettingManageVc.WatchManageDic.keys)[indexPath.row]
        cell.detailTextLabel?.text = ""
        // 矢印を入れる
        cell.accessoryType = .disclosureIndicator
    
        return cell
    }
    
    // セルが選択された場合
    override func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // セル選択時インデックス
        self.cellSelectIndex = indexPath.row
        // WatchSettingViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "showWatchSettingSegue",sender: nil)
    }
}
