//
//  History.swift
//  ARbuzApp
//
//  Created by Баранов Игорь Владиславович on 05.12.2022.
//

import Foundation

final class History {

	static let shared = History()

	private var responseModel: ResponseModel?

	private(set) var graphData: GraphData?

	func save(responseModel: ResponseModel) {
		self.responseModel = responseModel
		let middleValues = responseModel.results.map { ($0.l + $0.h)/2 }
		graphData = GraphData(ticker: responseModel.ticker, values: middleValues)
		saveResponseModelEach5Seconds()
	}

	private func saveResponseModelEach5Seconds() {
		let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerInvoked), userInfo: nil, repeats: true)
		RunLoop.main.add(timer, forMode: .common)
	}

	@objc
	private func timerInvoked() {
		if let lowPrice = responseModel?.results.min(by: { $0.l <= $1.l })?.l,
		   let highPrice = responseModel?.results.min(by: { $0.h >= $1.h })?.h {
			let randomDouble = Double.random(in: lowPrice...highPrice)
			graphData?.values.append(randomDouble)
		}
	}

}
