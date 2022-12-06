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

			network.request(for: company, dayFrom:
								randomDay,
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

		timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: timerTick)
	}

	func timerTick(_ timer: Timer) {
		if let completion = completion {
			fetchData(completion: completion)
		}

//		let names = ["Apple", "Microsoft", "Netflix"]
//		let colors = [UIColor.red, UIColor.blue, UIColor.yellow]
//		let bars = names.map { name in
//			ChartBar(name: name,
//					 value: Double.random(in: 0...1),
//					 money: "$ 100 500",
//					 color: colors.randomElement() ?? UIColor.lightGray)
//		}
//		let storage = ChartData(bars: bars)
//		completion?(storage)
		
	}
}
