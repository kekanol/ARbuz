//
//  ResponseModel.swift
//  ARbuzApp
//
//  Created by Баранов Игорь Владиславович on 05.12.2022.
//

import Foundation

struct ResponseModel: Codable {

	let ticker: String
	let queryCount, resultsCount: Int
	let adjusted: Bool
	let results: [Result]
	let status, requestID: String
	let count: Int

	enum CodingKeys: String, CodingKey {
		case ticker, queryCount, resultsCount, adjusted, results, status
		case requestID = "request_id"
		case count
	}
}

struct Result: Codable {
	let v: Int
	let vw, o, c, h: Double
	let l: Double
	let t, n: Int
}


struct GraphData {

	/// Название компании
	let ticker: String

	/// Средние цены на акции в выбранном промежутке
	var values: [Double]
}
