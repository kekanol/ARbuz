//
//  Network.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import Foundation

/// Структура для работы с сетью
struct Network {

	func request(for company: Company,
				 dayFrom: String = "2021-03-22",
				 dayTo: String = "2021-07-22",
				 completion: @escaping (ResponseModel) -> Void) {
		request(ticket: company.ticket,
				dayFrom: dayFrom,
				dayTo: dayTo,
				completion: completion)
	}
}

private extension Network {

	func request(ticket: String,
				 dayFrom: String = "2021-03-22",
				 dayTo: String = "2021-07-22",
				 completion: @escaping (ResponseModel) -> Void) {
		guard let url = URL(string: urlString(for: ticket,
											  dayFrom: dayFrom,
											  dayTo: dayTo)) else { return }
		DispatchQueue.global(qos: .userInitiated).async {
			let session = URLSession(configuration: .default)
			let request = URLRequest(url: url)
			let task = session.dataTask(with: request) { data, responce, error in
				if let data = data,
				   let response = try? JSONDecoder().decode(ResponseModel.self, from: data) {
					DispatchQueue.main.async {
						completion(response)
						History.shared.save(responseModel: response)
					}
				} else {
					guard let path = Bundle.main.path(forResource: ticket, ofType: "json"),
						  let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
						  let result = try? JSONDecoder().decode(ResponseModel.self, from: jsonData) else { return }
					completion(result)
					History.shared.save(responseModel: result)
				}
			}
			task.resume()
		}
	}

	func urlString(for ticket: String,
				   dayFrom: String,
				   dayTo: String) -> String {
		let base = "https://api.polygon.io/v2/aggs/ticker/"
		let suffix = "/range/1/day/\(dayFrom)/\(dayTo)?adjusted=true&sort=asc&limit=120&apiKey=4iYnPv1XjlUAHmxyFTM7L0KJCZoEqJhz"
		return base + ticket + suffix
	}
}
