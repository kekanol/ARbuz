//
//  BarChart.swift
//  ARbuzApp
//
//  Created by Миниахметов Дамир on 06.12.2022.
//

import Foundation
import ARKit

extension Sequence {
	func max<T: Comparable>(_ predicate: (Element) -> T)  -> Element? {
		self.max(by: { predicate($0) < predicate($1) })
	}
	func min<T: Comparable>(_ predicate: (Element) -> T)  -> Element? {
		self.min(by: { predicate($0) < predicate($1) })
	}
}

final class BarChart: SCNNode {

	private enum Constant {
		static let width: CGFloat = 0.5
		static let distanceBetweenBars: Float = Float(Constant.width / 2)
		static let chamferRadius: CGFloat = 0.01
		static let scaleFactor: Double = 2
	}

	private var chartData: ChartData
	private var hitTestResult: ARHitTestResult
	private var barGeometry: SCNPlane?
	private var floorNode: SCNNode?

	private var valueTextNodes: [SCNNode] = []
	private var nameTextNodes: [SCNNode] = []
	private var barNodes: [SCNNode] = []

	private var anchor: ARPlaneAnchor {
		hitTestResult.anchor as! ARPlaneAnchor
	}

	private var maxHeight: Float {
		let max = chartData.bars.max(\.value)
		return Float(max!.value)
	}

	private var hitPosition: SCNVector3 {
		SCNVector3(hitTestResult.worldTransform.columns.3.x,
				   hitTestResult.worldTransform.columns.3.y + 0.1,
				   hitTestResult.worldTransform.columns.3.z)
	}

	init(hitTestResult: ARHitTestResult, chartData: ChartData) {
		self.chartData = chartData
		self.hitTestResult = hitTestResult
		super.init()
		configure()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configure() {

		barGeometry = SCNPlane(width: CGFloat(anchor.extent.x),
							   height: CGFloat(anchor.extent.z))

		position = hitPosition

		addFloor()
		setupBars()
		setupTexts()
	}

	private func setupTexts() {
		for (index, point) in chartData.bars.enumerated() {
			let nameTextNode = createTextNode(with: chartData, index: index)
			nameTextNode.simdPosition = .init(
				x: position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
				y: position.y,
				z: barNodes[index].simdPosition.z + Float(Constant.width))

//			let quaternion = simd_quatf(angle: GLKMathDegreesToRadians(-45), axis: simd_float3(1,0,0))
//			textNode.simdOrientation = quaternion * textNode.simdOrientation

			let valueTextNode = createValueTextNode(with: chartData, index: index)
//			valueTextNode.simdPosition = .init(
//				x: position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
//				y: barNodes[index].simdPosition.y + maxHeight,
//				z: barNodes[index].simdPosition.z)

			valueTextNode.position = .init(
				x: position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
				y: barNodes[index].simdPosition.y + Constant.distanceBetweenBars + Float(point.value),
				z: barNodes[index].simdPosition.z)

			valueTextNodes.append(valueTextNode)
			nameTextNodes.append(nameTextNode)

			addChildNode(valueTextNode)
			addChildNode(nameTextNode)
		}
	}

	private func setupBars() {
		for (index, point) in chartData.bars.enumerated() {
			let box = SCNBox(width: Constant.width,
							 height: point.value * Constant.scaleFactor,
							 length: Constant.width,
							 chamferRadius: Constant.chamferRadius)
			box.firstMaterial?.diffuse.contents = point.color
			box.name = point.name

			let barNode = SCNNode(geometry: box)
			barNode.simdPosition = .init(position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
										 position.y,
										 position.z)

			barNodes.append(barNode)
			addChildNode(barNode)
		}
	}

	func createTextNode(with chartData: ChartData, index: Int) -> SCNNode {
		let newText = SCNText(string: "\(chartData.bars[index].name)" , extrusionDepth: 3)
		newText.firstMaterial!.diffuse.contents = chartData.bars[index].color
		newText.firstMaterial?.isDoubleSided = true

		let planeNode = SCNNode(geometry: newText)
		planeNode.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
		planeNode.name = "valueTextNode"

		let (minBound, maxBound) = newText.boundingBox
		let xPivot = (maxBound.x - minBound.x)/2
		let yPivot = minBound.y
		let zPivot = (maxBound.z - minBound.z)/2

		planeNode.pivot = SCNMatrix4MakeTranslation(xPivot, yPivot, zPivot)

		return planeNode
	}

	func createValueTextNode(with chartData: ChartData, index: Int) -> SCNNode {
		let newText = SCNText(string: "\(chartData.bars[index].money)" , extrusionDepth: 2)
		newText.firstMaterial!.diffuse.contents = chartData.bars[index].color
		newText.firstMaterial?.isDoubleSided = true

		let planeNode = SCNNode(geometry: newText)
		planeNode.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
		planeNode.name = "textNode"

		let (minBound, maxBound) = newText.boundingBox
		let xPivot = (maxBound.x - minBound.x)/2
		let yPivot = minBound.y
		let zPivot = (maxBound.z - minBound.z)/2

		planeNode.pivot = SCNMatrix4MakeTranslation(xPivot, yPivot, zPivot)

		return planeNode
	}

	func addFloor() {
		let floor = SCNFloor()
		floor.reflectivity = 0

		let material = SCNMaterial()
		material.diffuse.contents = UIColor.white
//		material.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 0)
//		// Координата текстуры S измеряет горизонтальную ось
		material.diffuse.wrapS = .repeat
//		// Координата текстуры T измеряет вертикальную ось
		material.diffuse.wrapT = .repeat

		let floorNode = SCNNode(geometry: floor)
		floorNode.position = hitPosition
		floorNode.geometry?.materials = [material]

		self.floorNode = floorNode
		addChildNode(floorNode)
	}

	/// Обновить данные
	/// - Parameter chartData: данные графика
	func update(chartData: ChartData) {
		self.chartData = chartData
		for index in 0 ..< barNodes.count {
			let targetGeometry = SCNBox(width: Constant.width,
										height: chartData.bars[index].value * Constant.scaleFactor,
										length: Constant.width,
										chamferRadius: Constant.chamferRadius)

			let morpher = SCNMorpher()
			morpher.targets = [targetGeometry]
			barNodes[index].morpher = morpher

			var textNode = createValueTextNode(with: chartData, index: index)

			textNode.simdPosition = .init(
				x: position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
				y: barNodes[index].simdPosition.y + Constant.distanceBetweenBars + Float(chartData.bars[index].value),
				z: barNodes[index].simdPosition.z)

			valueTextNodes[index].removeFromParentNode()
			addChildNode(textNode)

			valueTextNodes[index] = textNode



			let animation = CABasicAnimation(keyPath: "morpher.weights[0]")
			animation.toValue = 1.0
			animation.repeatCount = 0.0
			animation.duration = 1.0
			animation.fillMode = .both
			animation.isRemovedOnCompletion = false

			barNodes[index].addAnimation(animation, forKey: nil)
		}
	}

}
