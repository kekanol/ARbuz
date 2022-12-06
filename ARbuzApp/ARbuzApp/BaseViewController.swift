//
//  BaseViewController.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import UIKit

final class BaseViewController: UIViewController {
	private let elements = ["2D", "Bar", "Pie"]
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
		return elements.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = Self.Cell()
		cell.titleLabel.text = elements[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
			case 0: open2D()
			case 1: openBar()
			case 2: openPie()
			default: break
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func open2D() {
		let vc = GraphViewController()
		navigationController?.pushViewController(vc, animated: true)
	}

	func openPie() {
		print("openPie")
	}

	func openBar() {
		let barVC = BarChartController()
		self.present(barVC, animated: true)
	}
}

private extension BaseViewController {
	func setupUI() {
		view.addSubview(tableview)
		tableview.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableview.topAnchor.constraint(equalTo: view.topAnchor)
		])
	}

	final class Cell: UITableViewCell {
		static var reuseIdentifier: String? {
			"\(BaseViewController.Cell.self)"
		}

		let titleLabel = UILabel()

		init() {
			super.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
			titleLabel.font = .systemFont(ofSize: 24)
			addSubview(titleLabel)
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
				titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
				titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
				titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8)
			])
		}

		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
}
