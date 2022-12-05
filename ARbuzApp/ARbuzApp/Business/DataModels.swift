//
//  DataModels.swift
//  ARbuzApp
//
//  Created by Дьяконов Кирилл Михайлович on 05.12.2022.
//

import UIKit

/// Данные для графика
struct ChartData {
	var points: [ChartPoint]
}

/// Точка на графике
struct ChartPoint {
	let name: String

	/// 0 - 1
	let value: Double
	
	/// 100 $
	let money: String

	///
	let color: UIColor
}
