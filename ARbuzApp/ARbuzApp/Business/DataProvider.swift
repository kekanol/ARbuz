//
//  DataProvider.swift
//  ARbuzApp
//
//  Created by Дьяконов Кирилл Михайлович on 05.12.2022.
//

import Foundation
import UIKit

typealias ChartDataBlock = (ChartData) -> Void

protocol DataProviderProtocol {
	func fetchData(completion: @escaping ChartDataBlock)
}

final class DataProvider {

	private let network = Network()

	// TODO: storage
	private var storage = ChartData(points: [])

	private var completion: ChartDataBlock?

	private var timer: Timer?
}

extension DataProvider: DataProviderProtocol {

	func fetchData(completion: @escaping ChartDataBlock) {
		self.completion = completion
		network.request(for: .Apple) { model in
			print("network model: \(model)")
		}
		timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: timerTick)
	}
}

private extension DataProvider {

	func timerTick(_ timer: Timer) {
		let names = ["Apple", "Microsoft", "Netflix"]
		let colors = [UIColor.red, UIColor.blue, UIColor.yellow]
		let points = names.map { name in
			ChartPoint(name: name,
					   value: Double.random(in: 0...1),
					   money: "$ 100 500",
					   color: colors.randomElement() ?? UIColor.lightGray)
		}
		storage.points = points
		completion?(storage)
	}
}
