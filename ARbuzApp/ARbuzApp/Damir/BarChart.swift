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
		static let width: CGFloat = 0.3
		static let distanceBetweenBars: Float = 0.3 / 2
		static let chamferRadius: CGFloat = 0.1
		static let scaleFactor: Double = 1
	}

	private var chartData: ChartData
	private var hitTestResult: ARHitTestResult
	private var barGeometry: SCNPlane?
	private var bars: [SCNNode] = []

	private var anchor: ARPlaneAnchor {
		hitTestResult.anchor as! ARPlaneAnchor
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

		let material = SCNMaterial()
		material.diffuse.contents = UIColor.gray

		barGeometry!.materials = [material]

		geometry = barGeometry
		position = SCNVector3(anchor.center.x, 0, anchor.center.z)

		// Для отрисовки в горизонтали
//		transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1.0, 0.0, 0.0)

		setupBars()
		addFloor()
	}

	private func setupBars(scaleFactor: Double = 1) {

		for (index, point) in chartData.bars.enumerated() {
			let box = SCNBox(width: Constant.width,
							 height: point.value,
							 length: Constant.width,
							 chamferRadius: Constant.chamferRadius)
			box.firstMaterial?.diffuse.contents = point.color
			box.name = point.name

			let barNode = SCNNode(geometry: box)
			barNode.position = .init(position.x + Float(index) * (Float(Constant.width) + Constant.distanceBetweenBars),
									 position.y + Float(point.value / 2),
									 position.z)

			bars.append(barNode)
			addChildNode(barNode)
		}
	}

	private func addFloor() {
		let floor = SCNFloor()
		floor.reflectivity = 0.5

		let material = SCNMaterial()
		material.diffuse.contents = UIColor.lightGray
		material.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 0)
		// Координата текстуры S измеряет горизонтальную ось
		material.diffuse.wrapS = .repeat
		// Координата текстуры T измеряет вертикальную ось
		material.diffuse.wrapT = .repeat

		let floorNode = SCNNode(geometry: floor)
		floorNode.position = SCNVector3(x: 0, y: -0.1, z: 0)
		floorNode.geometry?.materials = [material]

		addChildNode(floorNode)
	}

//	/// Для обновления поверхности при вращении устройства
//	func update(anchor: ARPlaneAnchor) {
//		guard let barGeometry = barGeometry else { return }
//
//		barGeometry.width = CGFloat(anchor.extent.x)
//		barGeometry.height = CGFloat(anchor.extent.z)
//		position = SCNVector3(anchor.center.x, 0, anchor.center.z)
//
//		bars.forEach { $0.removeFromParentNode() }
//		setupBars()
//	}

	/// Обновить данные по нажатию
	/// - Parameter hitTestResult: результаты хит-теста
//	func update(hitTestResult: ARHitTestResult, parentNode: SCNNode) {
//		self.hitTestResult = hitTestResult
//		configure(parentNode: parentNode)
//	}

	/// Обновить данные
	/// - Parameter chartData: данные графика
	func update(chartData: ChartData, parentNode: SCNNode) {
//		bars.forEach { $0.removeFromParentNode() }
//		bars.removeAll()
//		self.chartData = chartData
//		configure(parentNode: parentNode)
		for index in 0 ..< bars.count {
			let targetGeometry = SCNBox(width: Constant.width,
										height: chartData.bars[index].value,
										length: Constant.width,
										chamferRadius: Constant.chamferRadius)
			let morpher = SCNMorpher()
			morpher.targets = [targetGeometry]
			bars[index].morpher = morpher

			let animation = CABasicAnimation(keyPath: "morpher.weights[0]")
			animation.toValue = 1.0
			animation.repeatCount = 0.0
			animation.duration = 1.0
			animation.fillMode = .forwards
			animation.isRemovedOnCompletion = false

			bars[index].addAnimation(animation, forKey: nil)
		}
	}

}
