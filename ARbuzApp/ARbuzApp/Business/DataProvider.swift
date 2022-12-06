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

	private var completion: ChartDataBlock?

	private var timer: Timer?

	private var companyResponces = [Company: ResponseModel]()
	
	private let lock = NSLock()

	private let companies: [Company] = [.Apple, .Microsoft]
}

extension DataProvider: DataProviderProtocol {

	func fetchData(completion: @escaping ChartDataBlock) {
		self.completion = completion
		let group = DispatchGroup()
		companies.forEach { company in
			group.enter()
			network.request(for: company) { [weak self] model in
				guard let self = self else { return }
				print("network model: \(model)")

				self.lock.lock()
				self.companyResponces[company] = model
				self.lock.unlock()

				group.leave()
			}
		}

		// Final
		group.notify(queue: DispatchQueue.main) { [weak self] in
			self?.updateData()
		}

		timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: timerTick)
	}
}

private extension DataProvider {

	func updateData() {
		
		var bars = [ChartBar]()
		companies.forEach { company in
			guard
				let responce = companyResponces[company],
				let lastResult = responce.results.last else { return }
			
			let bar = ChartBar(name: company.name,
							   value: Double.random(in: 0...1),
							   money: "$\(Int(lastResult.l))",
							   color: company.color)
			bars.append(bar)
		}
		let storage = ChartData(bars: bars)
		completion?(storage)
	}

	func timerTick(_ timer: Timer) {
		let names = ["Apple", "Microsoft", "Netflix"]
		let colors = [UIColor.red, UIColor.blue, UIColor.yellow]
		let bars = names.map { name in
			ChartBar(name: name,
					 value: Double.random(in: 0...1),
					 money: "$ 100 500",
					 color: colors.randomElement() ?? UIColor.lightGray)
		}
		let storage = ChartData(bars: bars)
		completion?(storage)
	}
}
