//
//  AppDelegate.swift
//  ios-google-calendar-demo
//
//  Created by Eiji Kushida on 2017/04/13.
//  Copyright © 2017年 Eiji Kushida. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //ユーザエージェントの設定
        UserDefaults.standard.register(defaults: ["UserAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602"])

        return true
    }
}
