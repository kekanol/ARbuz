//
//  BarChartController.swift
//  ARbuzApp
//
//  Created by Миниахметов Дамир on 05.12.2022.
//

import UIKit
import SceneKit
import ARKit

class BarChartController: UIViewController {

	private var sceneView: ARSCNView!

	private let configuration = ARWorldTrackingConfiguration()

	var planes = [Plane]()

	override func loadView() {
		sceneView = ARSCNView()
		view = sceneView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	    sceneView.session.delegate = self
		sceneView.delegate = self

		// Создаем сцену
		let scene = SCNScene()

		sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
		configuration.planeDetection = [.horizontal, .vertical]

		//addFloor(to: scene)
		configureTapGesture()
		sceneView.scene = scene
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		sceneView.session.run(configuration)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		sceneView.session.pause()
	}

}

// MARK: - Private methods

private extension BarChartController {

	func configureTapGesture() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(spawnChart))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
	}

	@objc func spawnChart(tapGesture: UITapGestureRecognizer) {
		guard let sceneView = tapGesture.view as? ARSCNView else { return }
		let tapLocation = tapGesture.location(in: sceneView)
		// Вектор к поверхности, если он пересекает какую-то поверхность, то попадает в результирующее значение
		guard let hitTestResult = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent).first else { return }

		let chartData = ChartData(points: [ChartPoint(name: "APPL", value: 0.7, money: "100", color: .black),
										   ChartPoint(name: "SBER", value: 1, money: "10000000", color: .green),
										   ChartPoint(name: "AMAZ", value: 0.1, money: "1", color: .blue)])

		createChart(chartData: chartData, hitTestResult: hitTestResult)
	}

	func createCube(_ hitTestResult: ARHitTestResult) {
		let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
								  hitTestResult.worldTransform.columns.3.y + 0.05,
								  hitTestResult.worldTransform.columns.3.z)

		let box = getCubeNode(size: 0.2,
							  position: position,
							  texture: UIColor.white)

		sceneView.scene.rootNode.addChildNode(box)
	}

	func getCubeNode(size: CGFloat, position: SCNVector3, texture: Any?) -> SCNNode {
		// Создаем геометрию - каркас
		let boxGeometry = SCNBox(
			width: size,
			height: size,
			length: size,
			chamferRadius: 0
		)

		// Создаем набор атрибутов, определяющих внешний вид поверхности геометрии при визуализации
		let material = SCNMaterial()
		material.diffuse.contents = texture

		// Структурный элемент графа сцены, представляющий положение и преобразование в трехмерном координатном пространстве, к которому вы можете прикрепить геометрию, источники света, камеры или другой отображаемый контент.
		let boxNode = SCNNode(geometry: boxGeometry)
		boxNode.geometry?.materials = [material]
		boxNode.position = position

		return boxNode
	}

	func addNewTextModel(text: String, scale: SCNVector3, position: SCNVector3, depth: CGFloat, color: UIColor, scene: SCNScene) {
		let textGeometry = SCNText(string: text, extrusionDepth: depth)

		let textMaterial = SCNMaterial()
		textMaterial.diffuse.contents = color

		let textNode = SCNNode(geometry: textGeometry)
		textNode.scale = scale
		textNode.geometry?.materials = [textMaterial]
		textNode.position = position

		scene.rootNode.addChildNode(textNode)
	}

	func createChart(chartData: ChartData, hitTestResult: ARHitTestResult) {
		let builder = BarBuilder()
		let barNode = builder.build(with: chartData, at: hitTestResult)
		sceneView.scene.rootNode.addChildNode(barNode)
	}

}

extension BarChartController: ARSCNViewDelegate {

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
		let plane = Plane(anchor: planeAnchor)

		planes.append(plane)
		node.addChildNode(plane)
	}

	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		let plane = planes.filter { $0.anchor.identifier == anchor.identifier }.first
		guard let uPlane = plane, let arAnchor = anchor as? ARPlaneAnchor else { return }

		uPlane.update(anchor: arAnchor)
	}

}

extension BarChartController: ARSessionDelegate {

	func session(_ session: ARSession, didFailWithError error: Error) {
	}

	func session(_ session: ARSession, didUpdate frame: ARFrame) {
	}
}

