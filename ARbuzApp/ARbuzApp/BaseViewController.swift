//
//  BaseViewController.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import UIKit

final class BaseViewController: UIViewController {
	private lazy var tableview: UITableView = {
		let table = UITableView(frame: .zero, style: .plain)
		table.delegate = self
		table.dataSource = self
		return table
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
}

extension BaseViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
}

private extension BaseViewController {
	func setupUI() {

	}
}
