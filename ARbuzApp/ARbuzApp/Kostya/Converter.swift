//
//  Converter.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import Foundation

final class Converter {
	var viewSize: CGSize = .zero {
		didSet {
			update()
		}
	}
	var viewCenter = CGPoint() {
		didSet {
			update()
		}
	}
	var models: [Result] = [] {
		didSet {
			update()
		}
	}
	private(set) var points: [CGPoint] = []

	private var minY: Double = 0
	private var maxY: Double = 0

	private var minX: Int = 0
	private var maxX: Int = 0

	private func update() {
		guard !models.isEmpty else { return }
		maxX = models.last!.t
		minX = models.last!.t
		minY = models.last!.c * 0.9
		maxY = models.last!.c * 1.1

		models.forEach { model in
			if model.h * 1.1 > maxY { maxY = model.c / 0.9 }
			if model.l * 0.9 < minY { minY = model.c * 0.9 }
			if model.t > maxX { maxX = model.t }
			if model.t < minX { minX = model.t }
		}

		var points = [CGPoint]()
		for element in models {
			var point = CGPoint()
			point.x = xPos(for: element)
			point.y = yPos(for: element, isTop: false)
			points.append(point)
		}

		for element in models.reversed() {
			var point = CGPoint()
			point.x = xPos(for: element)
			point.y = yPos(for: element, isTop: true)
			points.append(point)
		}

		self.points = points
	}

	private func yPos(for model: Result, isTop: Bool) -> CGFloat {
		let k = CGFloat(model.c - minY) / CGFloat(maxY - minY)
		let y = viewSize.height * k
		return y + (isTop ? CGFloat(0.05) : CGFloat(-0.05)) - viewSize.height / 2
	}

	private func xPos(for model: Result) -> CGFloat {
		let k = CGFloat(model.t - minX) / CGFloat(maxX - minX)
		let x = viewSize.width * k - viewSize.width / 2
		return x
	}
}
