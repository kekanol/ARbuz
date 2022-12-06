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
		static let width: CGFloat = 0.3 * Constant.scaleFactor
		static let distanceBetweenBars: Float = Float(0.3 / 2 * Constant.scaleFactor)
		static let chamferRadius: CGFloat = 0.005
		static let scaleFactor: Double = 0.4
	}

	private var chartData: ChartData
	private var hitTestResult: ARHitTestResult
	private var barGeometry: SCNPlane?
	private var bars: [SCNNode] = []
	private var floorNode: SCNNode?

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

			bars.append(barNode)
			addChildNode(barNode)
		}
	}

	func addFloor() {
		let floor = SCNFloor()
		floor.reflectivity = 0

		let material = SCNMaterial()
		material.diffuse.contents = UIColor.white
		material.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 0)
		// Координата текстуры S измеряет горизонтальную ось
		material.diffuse.wrapS = .repeat
		// Координата текстуры T измеряет вертикальную ось
		material.diffuse.wrapT = .repeat

		let floorNode = SCNNode(geometry: floor)
		floorNode.position = SCNVector3(x: 0, y: -0.1, z: 0)
		floorNode.geometry?.materials = [material]

		self.floorNode = floorNode
		addChildNode(floorNode)
	}

	/// Обновить данные
	/// - Parameter chartData: данные графика
	func update(chartData: ChartData) {
		for index in 0 ..< bars.count {
			let targetGeometry = SCNBox(width: Constant.width,
										height: chartData.bars[index].value * Constant.scaleFactor,
										length: Constant.width,
										chamferRadius: Constant.chamferRadius)

			let morpher = SCNMorpher()
			morpher.targets = [targetGeometry]
			bars[index].morpher = morpher

			let animation = CABasicAnimation(keyPath: "morpher.weights[0]")
			animation.toValue = 1.0
			animation.repeatCount = 0.0
			animation.duration = 1.0
			animation.fillMode = .both
			animation.isRemovedOnCompletion = false

			bars[index].addAnimation(animation, forKey: nil)
		}
	}

}
