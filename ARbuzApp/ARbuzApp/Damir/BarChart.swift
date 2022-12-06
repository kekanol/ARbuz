//
//  BarChart.swift
//  ARbuzApp
//
//  Created by Миниахметов Дамир on 06.12.2022.
//

import Foundation
import ARKit

final class BarChart: SCNNode {

	private enum Constant {
		static let width: CGFloat = 0.5 * Constant.scaleFactor
		static let distanceBetweenBars: Float = Float(Constant.width / 2 * Constant.scaleFactor)
		static let chamferRadius: CGFloat = 0.01
		static let scaleFactor: Double = 1
	}

	private var chartData: ChartData
	private var hitTestResult: ARHitTestResult
	private var barGeometry: SCNPlane?
	private var floorNode: SCNNode?

	private var nameTextNodes: [SCNNode] = []
	private var valueTextNodes: [SCNNode] = []
	private var barNodes: [SCNNode] = []

	private var anchor: ARPlaneAnchor {
		hitTestResult.anchor as! ARPlaneAnchor
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

		// Для отрисовки в горизонтали
//		transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1.0, 0.0, 0.0)

		addFloor()
		setupBars()
		setupTexts()
	}

	private func setupTexts() {
		for (index, point) in chartData.bars.enumerated() {
			let textNode = createTextNode(with: chartData, index: index)
			textNode.simdPosition = .init(x: position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
										  y: position.y,
										  z: barNodes[index].simdPosition.z + Float(Constant.width))

//			let quaternion = simd_quatf(angle: GLKMathDegreesToRadians(-45), axis: simd_float3(1,0,0))
//			textNode.simdOrientation = quaternion * textNode.simdOrientation
			barNodes[index].addChildNode(textNode)
			valueTextNodes.append(textNode)
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
		let newText = SCNText(string: "\(chartData.bars[index].name)" , extrusionDepth: 0)
		newText.font = UIFont (name: "Arial", size: 0.12)//.systemFont(ofSize: 0.05)
		newText.firstMaterial!.diffuse.contents = chartData.bars[index].color
		newText.firstMaterial?.isDoubleSided = true

		let planeNode = SCNNode(geometry: newText)
		planeNode.name = "textNode"

		let (minBound, maxBound) = newText.boundingBox
		let xPivot = (maxBound.x - minBound.x)/2
		let yPivot = (maxBound.y - minBound.y)/2
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
		for index in 0 ..< barNodes.count {
			let targetGeometry = SCNBox(width: Constant.width,
										height: chartData.bars[index].value * Constant.scaleFactor,
										length: Constant.width,
										chamferRadius: Constant.chamferRadius)

			let morpher = SCNMorpher()
			morpher.targets = [targetGeometry]
			barNodes[index].morpher = morpher

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
