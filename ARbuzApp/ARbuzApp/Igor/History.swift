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

	private(set) var graphData: [Result] = []

	func save(responseModel: ResponseModel) {
		self.responseModel = responseModel
		graphData = responseModel.results
		saveResponseModelEach5Seconds()
	}

	private func saveResponseModelEach5Seconds() {
		let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerInvoked), userInfo: nil, repeats: true)
		RunLoop.main.add(timer, forMode: .common)
	}

	@objc
	private func timerInvoked() {
		if let last = graphData.last {
			let random = Bool.random()
			let randomDouble = random ? last.c * 1.01 : last.c * 0.99
			let preLast = graphData[graphData.count - 2]
			let time = last.t - preLast.t + last.t

			let result = Result(v: preLast.v, vw: preLast.vw, o: last.c, c: randomDouble, h: last.c, l: last.c, t: time, n: last.n)
			graphData.append(result)
			graphData.remove(at: 0)
			graphDataDidUpdate()
		}
	}

	private func graphDataDidUpdate() {
		NotificationCenter.default.post(name: NSNotification.Name("graphDataDidUpdate"), object: nil)
	}
}
