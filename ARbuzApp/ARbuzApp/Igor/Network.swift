//
//  Network.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import Foundation

struct Network {

	private let urlString = "https://api.polygon.io/v2/aggs/ticker/AAPL/range/1/day/2021-03-12/2021-07-22?adjusted=true&sort=asc&limit=120&apiKey=4iYnPv1XjlUAHmxyFTM7L0KJCZoEqJhz"

	func requestModel(_ completion: @escaping (ResponseModel) -> Void) {
		DispatchQueue.global(qos: .userInitiated).async {
			let url = URL(string: urlString)!
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
}
