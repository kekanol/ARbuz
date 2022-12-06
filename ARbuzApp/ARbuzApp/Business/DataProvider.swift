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

	private let companies: [Company] = [.Apple, .Microsoft, .AMD, .Alibaba]
	
	private let daysForFetching = ["2021-01-22",
								   "2021-02-22",
								   "2021-03-22",
								   "2021-04-22",
								   "2021-05-22",
								   "2021-06-22",
								   "2021-07-22",
								   "2021-08-22",
								   "2021-09-22",
								   "2021-10-22",
								   "2021-11-22",
								   "2021-12-22",
	]
}

extension DataProvider: DataProviderProtocol {

	func fetchData(completion: @escaping ChartDataBlock) {
		self.completion = completion

		let randomDay = daysForFetching.randomElement() ?? "2021-01-01"
		let group = DispatchGroup()
		companies.forEach { company in
			group.enter()

			network.request(for: company,
							dayFrom: randomDay,
							dayTo: randomDay) { [weak self] model in
				guard let self = self else { return }

				print("Fetched \(company) for \(randomDay)")

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
	}
}

private extension DataProvider {

	func updateData() {
		var bars = [ChartBar]()
		let max = companyResponces.values.map ({ $0.results[0].c }).max() ?? 0
		companies.forEach { company in
			guard
				let responce = companyResponces[company],
				let lastResult = responce.results.randomElement() else { return }

			let money = value(for: lastResult.c, below: max)
			let bar = ChartBar(name: company.name,
							   value: money,
							   money: "$\(Int(lastResult.c))",
							   color: company.color)
			bars.append(bar)
		}
		let storage = ChartData(bars: bars)
		completion?(storage)

		Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: timerTick)
	}

	func timerTick(_ timer: Timer) {
		if let completion = completion {
			fetchData(completion: completion)
		}
	}

	func value(for number: Double, below max: Double) -> Double {
		let result = number / max
		return result
	}
}
