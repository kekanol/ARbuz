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

	private let rootNode: SCNNode
	private let chartData: ChartData
	private let hitTestResult: ARHitTestResult

	private var hitPosition: SCNVector3 {
		SCNVector3(hitTestResult.worldTransform.columns.3.x,
				   hitTestResult.worldTransform.columns.3.y + 0.1,
				   hitTestResult.worldTransform.columns.3.z)
	}

	init(chartData: ChartData, hitTestResult: ARHitTestResult) {
		self.chartData = chartData
		self.hitTestResult = hitTestResult
		self.rootNode = SCNNode()
		rootNode.position = hitPosition
	}

	@discardableResult
	func setupBars(width: CGFloat = 0.3,
				   scaleFactor: Double = 1,
				   distanceBetweenBars: Float = 0.3 / 2,
				   chamferRadius: CGFloat = 0.1) -> BarBuilder {

		for (index, point) in chartData.bars.enumerated() {
			let box = SCNBox(width: width, height: point.value, length: width, chamferRadius: chamferRadius)
			box.firstMaterial?.diffuse.contents = point.color
			box.name = point.name

			let boxNode = SCNNode(geometry: box)
			boxNode.position = .init(hitPosition.x + Float(index) * (Float(width) + distanceBetweenBars),
									 hitPosition.y + Float(point.value / 2),
									 hitPosition.z)

			rootNode.addChildNode(boxNode)
		}
		return self
	}

	@discardableResult
	func build(at scene: SCNScene) -> SCNNode {
		scene.rootNode.addChildNode(rootNode)
		return rootNode
	}
}
