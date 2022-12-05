//
//  BarBuilder.swift
//  ARbuzApp
//
//  Created by Миниахметов Дамир on 05.12.2022.
//

import Foundation
import ARKit
import SceneKit

final class BarBuilder {

	private let chartData: ChartData

	init(chartData: ChartData) {
		self.chartData = chartData
	}

	@discardableResult
	func build(at hitTestResult: ARHitTestResult,
			   width: CGFloat = 0.3,
			   scaleFactor: Double = 1,
			   distanceBetweenBlocks: Float = 0.3 / 2,
			   chamferRadius: CGFloat = 0.1) -> SCNNode {
		let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
								  hitTestResult.worldTransform.columns.3.y + 0.1,
								  hitTestResult.worldTransform.columns.3.z)
		let coreNode = SCNNode()
		coreNode.position = position

		for (index, point) in chartData.bars.enumerated() {
			let box = SCNBox(width: width, height: point.value, length: width, chamferRadius: chamferRadius)
			box.firstMaterial?.diffuse.contents = point.color
			box.name = point.name

			let boxNode = SCNNode(geometry: box)
			boxNode.position = .init(position.x + Float(index) * (Float(width) + distanceBetweenBlocks),
									 position.y + Float(point.value / 2),
									 position.z)

			coreNode.addChildNode(boxNode)
		}
		return coreNode
	}
}
