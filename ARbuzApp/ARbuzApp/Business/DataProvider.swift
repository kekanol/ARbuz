//
//  DataProvider.swift
//  ARbuzApp
//
//  Created by Дьяконов Кирилл Михайлович on 05.12.2022.
//

import Foundation

typealias ChartDataBlock = (ChartData) -> Void

protocol DataProviderProtocol {
	func fetchData(completion: @escaping ChartDataBlock)
}

final class DataProvider {

	// TODO: Use Network loader

	// TODO: storage
	private var storage = ChartData(points: [])

	private var completion: ChartDataBlock?

	private var timer: Timer?
}

extension DataProvider: DataProviderProtocol {

	func fetchData(completion: @escaping ChartDataBlock) {
		self.completion = completion
		timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: timerTick)
	}
}

private extension DataProvider {

	func timerTick(_ timer: Timer) {
		let data = Double.random(in: 0...1)
		print("\(data)")
		completion?(storage)
	}
}
