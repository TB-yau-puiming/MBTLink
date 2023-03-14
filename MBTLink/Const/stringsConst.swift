//
//  StringsConst.swift
//  MBTLink
//
//  Created by 開発用treebell003 on 2022/11/24.
// 今後定数をアッパースネークケースで統一する

import Foundation

struct StringsConst {
    // MARK: 元言語
    static let server_settings = "サーバー設定"
    static let location_notification_settings = "位置通知設定"
    static let measuring_device_settings = "計測器設定"
    static let wearable_device_settings = "ウェアラブルデバイス設定管理"
    static let wearable_device_selection = "ウェアラブルデバイス選択"
    static let wearable_settings = "ウェアラブル設定"
    //static let
    static let language = "日本語"
    static let watch_connection_status = "ウォッチ接続状態"
    static let Back = "戻る"
    static let connected = "接続中"
    static let not_connected = "未接続"
    static let low = "低"
    static let medium = "中"
    static let high = "高"
    static let done = "完了"
    static let cancel = "キャンセル"
    static let environment_sensor_settings = "環境センサー設定"
    static let device_settings = "機器設定"
    static let not_configured = "未設定"
    static let confugured = "設定済み"
    static let environment_sensor_name = "オムロン環境センサ 2JCIE-BL01"
    static let weight_scale_name = "A&D 体重計 UC-352BLE"
    static let blood_pressure_monitor_name = "A&D 血圧計 UA-651BLE"
    static let thermometer_name = "A&D 体温計 UT-201BLE"
    static let pulse_oximeter_name = "A&D パルスオキシメータTM1121"
    static let connecting = "接続中..."
    static let searching = "探索中..."
    static let start_pairing = "ペアリング開始"
    static let unpairing = "ペアリング解除"
    static let stop_scanning = "スキャン停止"
    static let bd_address_or_serial_number = "BDアドレスまたはシリアルナンバー"
    static let serial_number = "シリアル番号"
    static let device_id = "機器ID"
    static let minutes = "分"
    static let three_minutes = "3分"
    static let five_minutes = "5分"
    static let ten_minutes = "10分"
    static let thirty_minutes = "30分"
    static let decision = "決定"
    static let unpair_message = "ペアリングを解除しますか？"
    static let unpair = "解除"
    static let pair_message = "とペアリングしてよろしいですか？"
    static let question_mark = "?"
    static let confirm = "確認"
    static let ok = "OK"
    static let watch_unpair_message_a = "ペアリング情報がアプリから削除されますが、iOSの設定に残る場合があります。"
    static let watch_unpair_message_b = "「設定」-「Bluetooth」を開き「自分のデバイス」に削除済みのデバイスが表示されている場合は、iアイコンをタップしデバイスの登録を解除するか、Bluetooth機能を一度無効にし再度有効にしてください。"
    // ヘッダー、フッター
    static let function = "機能"
    static let notification_application = "通知アプリ"
    static let user_setting_header_a = "設定情報を入力し、「戻る」を実行してください。"
    static let user_setting_header_b = "なお、設定情報を全て消す場合は「設定クリア」を実行してください。"
    static let location_info_setting_footer_a = "・MAPサービスをご利用の際には「位置情報を送信する」をONにしてください"
    static let location_info_setting_footer_b = "・位置情報送信中はGPSを使用するためバッテリーを著しく消耗することがあります。"
    static let location_info_setting_footer_c = "・受信レベルは低→中→高の順に測位精度が上がりますがバッテリー消費は早まります。"
    static let measuring_instrument_setting_footer_a = "環境センサーの電池を交換した際には再度ペアリングしてください。"
    // MARK: 翻訳
    static let Server_Settings = NSLocalizedString(server_settings, comment: "")
    static let Location_Notification_Settings = NSLocalizedString(location_notification_settings, comment: "")
    static let Measuring_Device_Settings = NSLocalizedString(measuring_device_settings, comment: "")
    static let Wearable_Device_Settings = NSLocalizedString(wearable_device_settings, comment: "")
    static let Wearable_Device_Selection = NSLocalizedString(wearable_device_selection, comment: "")
    static let Wearable_Settings = NSLocalizedString(wearable_settings, comment: "")
    static let LANGUAGE = NSLocalizedString(language, comment: "")
    static let WATCH_CONNECTION_STATUS = NSLocalizedString(watch_connection_status, comment: "")
    static let BACK = NSLocalizedString(Back, comment: "")
    static let CONNECTED = NSLocalizedString(connected, comment: "")
    static let NOT_CONNECTED = NSLocalizedString(not_connected, comment: "")
    static let LOW = NSLocalizedString(low, comment: "")
    static let MEDIUM = NSLocalizedString(medium, comment: "")
    static let HIGH = NSLocalizedString(high, comment: "")
    static let DONE = NSLocalizedString(done, comment: "")
    static let CANCEL = NSLocalizedString(cancel, comment: "")
    static let NOT_CONFIGURED = NSLocalizedString(not_configured, comment: "")
    static let CONFIGURED = NSLocalizedString(confugured, comment: "")
    static let ENVIRONMENT_SENSOR_SETTINGS = NSLocalizedString(environment_sensor_settings, comment: "")
    static let DEVICE_SETTINGS = NSLocalizedString(device_settings, comment: "")
    static let ENVIRONMENT_SENSOR_NAME = NSLocalizedString(environment_sensor_name, comment: "")
    static let WEIGHT_SCALE_NAME = NSLocalizedString(weight_scale_name, comment: "")
    static let BLOOD_PRESSURE_MONITOR_NAME =  NSLocalizedString(blood_pressure_monitor_name, comment: "")
    static let THERMOMETER_NAME = NSLocalizedString(thermometer_name, comment: "")
    static let PULSE_OXIMETER_NAME = NSLocalizedString(pulse_oximeter_name, comment: "")
    static let CONNECTING = NSLocalizedString(connecting, comment: "")
    static let SEARCHING = NSLocalizedString(searching, comment: "")
    static let START_PAIRING = NSLocalizedString(start_pairing, comment: "")
    static let UNPAIRING = NSLocalizedString(unpairing, comment: "")
    static let STOP_SCANNING = NSLocalizedString(stop_scanning, comment: "")
    static let BD_ADDRESS_OR_SERIAL_NUMBER =  NSLocalizedString(bd_address_or_serial_number, comment: "")
    static let SERIAL_NUMBER =  NSLocalizedString(serial_number, comment: "")
    static let DEVICE_ID = NSLocalizedString(device_id, comment: "")
    static let MINUTES = NSLocalizedString(minutes, comment: "")
    static let THREE_MINUTES = NSLocalizedString(three_minutes, comment: "")
    static let FIVE_MINUTES = NSLocalizedString(five_minutes, comment: "")
    static let TEN_MINUTES = NSLocalizedString(ten_minutes, comment: "")
    static let THIRTY_MINUTES = NSLocalizedString(thirty_minutes, comment: "")
    static let DECISION = NSLocalizedString(decision, comment: "")
    static let UNPAIR_MESSAGE = NSLocalizedString(unpair_message, comment: "")
    static let UNPAIR = NSLocalizedString(unpair, comment: "")
    static let PAIR_MESSAGE = NSLocalizedString(pair_message, comment: "")
    static let QUESTION_MARK = NSLocalizedString(question_mark, comment: "")
    static let CONFIRM = NSLocalizedString(confirm, comment: "")
    static let OK = NSLocalizedString(ok, comment: "")
    static let WATCH_UNPAIR_MESSAGE_A = NSLocalizedString(watch_unpair_message_a, comment: "")
    static let WATCH_UNPAIR_MESSAGE_B = NSLocalizedString(watch_unpair_message_b, comment: "")
    // ヘッダー、フッター
    static let Function =  NSLocalizedString(function, comment: "")
    static let Notification_Application =  NSLocalizedString(notification_application, comment: "")
    static let USER_SETTING_HEADER_A = NSLocalizedString(user_setting_header_a, comment: "")
    static let USER_SETTING_HEADER_B = NSLocalizedString(user_setting_header_b, comment: "")
    static let LOCATION_INFO_SETTING_FOOTER_A =  NSLocalizedString(location_info_setting_footer_a, comment: "")
    static let LOCATION_INFO_SETTING_FOOTER_B =  NSLocalizedString(location_info_setting_footer_b, comment: "")
    static let LOCATION_INFO_SETTING_FOOTER_C =  NSLocalizedString(location_info_setting_footer_c, comment: "")
    static let MEASURING_INSTRUMENT_SETTING_FOOTER_A =  NSLocalizedString(measuring_instrument_setting_footer_a, comment: "")
    
    // MARK: ログレベル
    static let DEBUG = "DEBUG"
    static let INFO = "INFO"
    static let ACTION = "ACTION"
    static let WARN = "WARN"
    static let ERROR = "ERROR"
}
