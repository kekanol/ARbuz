//
//  AppDelegate.swift
//  ARbuzApp
//
//  Created by Миниахметов Дамир on 05.12.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow()
		let navVC = UINavigationController(rootViewController: BaseViewController())
		window?.rootViewController = navVC
		return true
	}
}

