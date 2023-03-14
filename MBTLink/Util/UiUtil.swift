//
//  UiUtil.swift
//  MBTLink
//
//  Created by school on 2022/02/02.
//

import Foundation
import UIKit

class UiUti{
    // MARK: - Private変数
    /// クラス名
    private let className = String(String(describing: UiUti.self).split(separator: "-")[0])
    internal static func show(_ text: String, _ parent: UIView) {
            let label = UILabel()
            let width = parent.frame.size.width
            let height = parent.frame.size.height / 15
            var bottomPadding = 0.0
            if #available(iOS 13.0, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                if let window = windowScene?.windows.first {
                    bottomPadding = Double(window.safeAreaInsets.bottom)
                }
            }
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.textColor = UIColor.white
            label.textAlignment = .center;
            label.text = text
             
        label.frame = CGRect(x: parent.frame.size.width / 2 - (width / 2), y: parent.frame.size.height - height * 3 - CGFloat(bottomPadding), width: width, height: height)
            parent.addSubview(label)
             
            UIView.animate(withDuration: 1.0, delay: 3.0, options: .curveEaseOut, animations: {
                label.alpha = 0.0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        //システムログ作成、送信
        LogUtil.createSystemLog(logLevel:StringsConst.DEBUG , className: UiUti().className , functionName: #function , message: "")
        }
    }
