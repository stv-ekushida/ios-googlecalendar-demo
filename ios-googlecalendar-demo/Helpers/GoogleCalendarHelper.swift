//
//  GoogleCalendarHelper.swift
//  ios-google-calendar-demo
//
//  Created by Eiji Kushida on 2017/04/14.
//  Copyright © 2017年 Eiji Kushida. All rights reserved.
//

import Foundation
import GoogleAPIClient
import GTMOAuth2

enum CalendarStatus {
    case authCompletion
    case loaded(events: [String])
    case failure(message: String)
}

protocol GoogleCalendarDelegate: class {
    func complated(status: CalendarStatus)
}

final class GoogleCalendarHelper: NSObject {

    weak var delegate: GoogleCalendarDelegate?

    private let kKeychainItemName = "Google Calendar API"

    //TODO : クライアントIDを設定する
    private let kClientID = ""

    private let scopes = [kGTLAuthScopeCalendar]
    private let service = GTLServiceCalendar()

    fileprivate var calendarID = ""

    //MARK : - 認証関連
    /// キーチェーンに保存されている認証情報を取得する
    func loadAuth() {

        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName: kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
    }

    /// 認証されているか？
    func canAuth() -> Bool {

        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize, canAuth {
            return true
        } else {
            return false
        }
    }

    /// 認証画面を生成する
    func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joined(separator: " ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(self.viewController)
        )
    }

    /// 認証完了後に呼ばれるメソッド
    func viewController(vController: UIViewController,
                        finishedWithAuth authResult: GTMOAuth2Authentication,
                        error: NSError?) {

        if let error = error {
            service.authorizer = nil
            delegate?.complated(status: .failure(message:error.localizedDescription))
            return
        }

        service.authorizer = authResult
        delegate?.complated(status: .authCompletion)
    }

    //MARK : - イベント取得
    /// カレンダーのイベント情報を取得する
    func fetchEvents() {
        let query = GTLQueryCalendar.queryForEventsList(withCalendarId: "primary")
        query?.maxResults = 10
        query?.timeMin = GTLDateTime(date: Date(),
                                     timeZone: NSTimeZone.local)
        query?.singleEvents = true
        query?.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query!,
            delegate: self,
            didFinish: #selector(self.displayResultWithTicket)
        )
    }

    /// イベント情報を表示する
    func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject response: GTLCalendarEvents,
        error: NSError?) {

        if let error = error {
            delegate?.complated(status: .failure(message:error.localizedDescription))
            return
        }

        var eventString = ""

        if let events = response.items(), !events.isEmpty {

            if let evnets = events as? [GTLCalendarEvent] {

                for event in evnets {
                    let start: GTLDateTime! = event.start.dateTime ?? event.start.date
                    let startString = DateFormatter.localizedString(
                        from: start.date,
                        dateStyle: .short,
                        timeStyle: .short
                    )
                    eventString += "\(startString) - \(event.summary!)\n"
                }
            }
        } else {
            eventString = "No upcoming events found."
        }

        if let caladarID = response.summary {
            self.calendarID = caladarID
        }

        let events = eventString.components(separatedBy: "\n")
        delegate?.complated(status: .loaded(events: events))
    }

    //MARK : - イベント登録
    /// イベントを登録する
    func addEvent(summary: String, startTime: Date, endTime: Date) {

        let event = GTLCalendarEvent()
        event.start = GTLCalendarEventDateTime()
        event.start.dateTime = GTLDateTime(date: startTime, timeZone: NSTimeZone.system)
        event.end = GTLCalendarEventDateTime()
        event.end.dateTime = GTLDateTime(date: endTime, timeZone: NSTimeZone.system)
        event.summary = summary

        let query = GTLQueryCalendar.queryForEventsInsert(withObject: event,
                                                          calendarId: self.calendarID)

        self.service.executeQuery(query!) { _, event, error in

            if error == nil {
                print(event.debugDescription)
            } else {
                print("event add ng: \(error.debugDescription)")
            }
        }
    }
}
