//
// WebViewController.swift
// Web画面
//
// MBTLink
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    // MARK: - UI部品
    /// WebView
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Public変数
    /// URL
    public var UrlString : String?
    /// タイトル名
    public var TitleName : String = ""
    
    // MARK: - イベント関連
    /// viewがロードされた後に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // back -> 戻るに変更
        let backbutton = UIBarButtonItem()
        backbutton.title = StringsConst.BACK
        self.navigationItem.backBarButtonItem = backbutton
        
        // URLリクエスト
        guard let string = self.UrlString else { return }
        let url = URL(string: string)
        let request = URLRequest(url: url!)
        
        // ナビゲーションタイトル
        self.navigationItem.title = self.TitleName
        
        // Webページを開く
        self.webView.load(request)
    }
}
