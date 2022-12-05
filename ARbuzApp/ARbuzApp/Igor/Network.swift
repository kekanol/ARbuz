//
//  Network.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import Foundation

enum Company: String {
	case Apple = "AAPL"
	case Microsoft = "MSFT"
	case AMD = "AMD"
	case Alibaba = "BABA"
}


struct Network {

	func request(for company: Company,
				 completion: @escaping (ResponseModel) -> Void) {
		request(for: company.rawValue, completion: completion)
	}
}

private extension Network {

	func request(for ticket: String,
				 completion: @escaping (ResponseModel) -> Void) {
		guard let url = URL(string: urlString(for: ticket)) else { return }
		DispatchQueue.global(qos: .userInitiated).async {
			let session = URLSession(configuration: .default)
			let request = URLRequest(url: url)
			let task = session.dataTask(with: request) { data, responce, error in
				if let data = data,
				   let responce = try? JSONDecoder().decode(ResponseModel.self, from: data){
					DispatchQueue.main.async {
						completion(responce)
					}
				}
			}
			task.resume()
		}
	}

	func urlString(for ticket: String) -> String {
		let base = "https://api.polygon.io/v2/aggs/ticker/"
		let suffix = "/range/1/day/2021-03-12/2021-07-22?adjusted=true&sort=asc&limit=120&apiKey=4iYnPv1XjlUAHmxyFTM7L0KJCZoEqJhz"
		return base + ticket + suffix
	}
}
