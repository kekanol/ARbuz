//
//  DataModels.swift
//  ARbuzApp
//
//  Created by Дьяконов Кирилл Михайлович on 05.12.2022.
//

import UIKit

enum Company: String {
	case Apple
	case Microsoft
	case AMD
	case Alibaba

	var name: String {
		rawValue
	}

	var ticket: String {
		switch self {
		case .Apple: return "AAPL"
		case .Microsoft: return "MSFT"
		case .AMD: return "AMD"
		case .Alibaba: return "BABA"
		}
	}

	var color: UIColor {
		switch self {
		case .Apple: return .cyan
		case .Microsoft: return .blue
		case .AMD: return .brown
		case .Alibaba: return .orange
		}
	}
}

/// Данные для графика
struct ChartData {
	var bars: [ChartBar]
}

/// Полоска на графике
struct ChartBar {
	let name: String

	/// 0 - 1
	let value: Double
	
	/// 100 $
	let money: String

	///
	let color: UIColor
}

