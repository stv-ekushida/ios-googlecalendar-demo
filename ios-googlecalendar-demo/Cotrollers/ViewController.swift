//
//  ViewController.swift
//  ios-google-calendar-demo
//
//  Created by Eiji Kushida on 2017/04/13.
//  Copyright © 2017年 Eiji Kushida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var calendar = GoogleCalendarHelper()

    //MARK : - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        calendar.delegate = self
        calendar.loadAuth()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if calendar.canAuth() {
            calendar.fetchEvents()

        } else {
            present(
                calendar.createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }

    //MARK : - Actions
    @IBAction func didTapAddEvent(_ sender: UIButton) {
        createEvent()
    }

    /// テストデータ
    private func createEvent() {

        let calandar = Calendar.current
        var compornets = DateComponents()
        compornets.year = 2017
        compornets.month = 4
        compornets.day = 14
        compornets.hour = 10
        let startTime = calandar.date(from: compornets)
        let endTime = startTime?.addingTimeInterval(3600 * 2)

        if let startTime = startTime, let endTime = endTime {

            calendar.addEvent(summary: "テストイベント",
                              startTime: startTime,
                              endTime: endTime)
        }
    }
}

// MARK: - GoogleCalendarDelegate
extension ViewController: GoogleCalendarDelegate {

    func complated(status: CalendarStatus) {

        switch status {
        case .authCompletion:
            dissmissAuthController()

        case .loaded(let events):
            renderEvent(events: events)

        case .failure(let message):
            showAlert(title: "エラー", message: message)
        }
    }

    /// 認証画面を閉じる
    private func dissmissAuthController() {
        dismiss(animated: true, completion: nil)
    }

    /// イベントを表示する
    ///
    /// - Parameter events: イベント一覧
    private func renderEvent(events: [String]) {

        _ = events.map {
            print($0)
        }
    }

    /// アラートを表示する
    ///
    /// - Parameters:
    ///   - title: アラートタイトル
    ///   - message: アラートメッセージ
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
