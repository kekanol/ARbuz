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

	@discardableResult
	func build(with chartData: ChartData, at hitTestResult: ARHitTestResult, scaleFactor: Double = 1) -> SCNNode {
		let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
								  hitTestResult.worldTransform.columns.3.y + 0.05,
								  hitTestResult.worldTransform.columns.3.z)
		let coreNode = SCNNode()
		coreNode.position = position

		for (index, point) in chartData.points.enumerated() {
			let box = SCNBox(width: 0.5, height: point.value, length: 0.5, chamferRadius: 0.01)
			box.firstMaterial?.diffuse.contents = point.color
			box.name = point.name

			let boxNode = SCNNode(geometry: box)
			boxNode.position = .init(position.x + Float(index) * 0.5 + 0.2, position.y, position.z)

			coreNode.addChildNode(boxNode)
		}
		return coreNode
	}
}
