//
//  BarChartController.swift
//  ARbuzApp
//
//  Created by Миниахметов Дамир on 05.12.2022.
//

import UIKit
import SceneKit
import ARKit

//final class BarChartViewModel {
//
//	private let provider: DataProviderProtocol
//
//	private var hitPosition: SCNVector3?
//	private var chartData: ChartData {
//		didSet {
//			guard let hitPosition = hitPosition else { return }
//			DispatchQueue.main.async { self.update(self.chartData, hitPosition) }
//		}
//	}
//
//	var update: (_ chartData: ChartData, _ hitPosition: SCNVector3) -> Void = {_, _ in}
//
//	init(provider: DataProviderProtocol) {
//		self.provider = provider
//
//		provider.fetchData { [weak self] chartData in
//			self?.chartData = chartData
//		}
//	}
//
//	func tap(at hitPosition: SCNVector3) {
//		self.hitPosition = hitPosition
//		self.update(self.chartData, hitPosition)
//	}
//
//	func clear() {
//		hitPosition = nil
//	}
//}

final class BarChartController: UIViewController {

	private var sceneView: ARSCNView!

	private let configuration = ARWorldTrackingConfiguration()
	private let provider: DataProviderProtocol

	private var barChart: BarChart?
	private var planes = [Plane]()

	private var chartData: ChartData?

	init(provider: DataProviderProtocol) {
		self.provider = provider
		super.init(nibName: nil, bundle: nil)

		provider.fetchData { [weak self] chartData in
			guard let self = self else { return }
			self.chartData = chartData
			self.barChart?.update(chartData: chartData, parentNode: self.sceneView.scene.rootNode)
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

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
		guard let hitTestResult = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent).first,
			  let chartData = chartData else { return }

		let barChart = BarChart(hitTestResult: hitTestResult, chartData: chartData)
		self.barChart = barChart
		sceneView.scene.rootNode.addChildNode(barChart)

//		self.hitTestResult = hitTestResult
//		createChartIfNeeded()
//
//		if let chartData = chartData {
//			(chartData: chartData, hitTestResult: hitTestResult)
//		}
	}

//	func createCube(_ hitTestResult: ARHitTestResult) {
//		let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
//								  hitTestResult.worldTransform.columns.3.y + 0.05,
//								  hitTestResult.worldTransform.columns.3.z)
//
//		let box = getCubeNode(size: 0.2,
//							  position: position,
//							  texture: UIColor.white)
//
//		sceneView.scene.rootNode.addChildNode(box)
//	}
//
//	func getCubeNode(size: CGFloat, position: SCNVector3, texture: Any?) -> SCNNode {
//		// Создаем геометрию - каркас
//		let boxGeometry = SCNBox(
//			width: size,
//			height: size,
//			length: size,
//			chamferRadius: 0
//		)
//
//		// Создаем набор атрибутов, определяющих внешний вид поверхности геометрии при визуализации
//		let material = SCNMaterial()
//		material.diffuse.contents = texture
//
//		// Структурный элемент графа сцены, представляющий положение и преобразование в трехмерном координатном пространстве, к которому вы можете прикрепить геометрию, источники света, камеры или другой отображаемый контент.
//		let boxNode = SCNNode(geometry: boxGeometry)
//		boxNode.geometry?.materials = [material]
//		boxNode.position = position
//
//		return boxNode
//	}

//	func addNewTextModel(text: String, scale: SCNVector3, position: SCNVector3, depth: CGFloat, color: UIColor, scene: SCNScene) {
//		let textGeometry = SCNText(string: text, extrusionDepth: depth)
//
//		let textMaterial = SCNMaterial()
//		textMaterial.diffuse.contents = color
//
//		let textNode = SCNNode(geometry: textGeometry)
//		textNode.scale = scale
//		textNode.geometry?.materials = [textMaterial]
//		textNode.position = position
//
//		scene.rootNode.addChildNode(textNode)
//	}
//
//	func createChartIfNeeded() {
//		guard let chartData = chartData,
//			  let hitTest else { return }
//		createChart(chartData: ChartData, hitTestResult: ARHitTestResult)
//	}

//	func createChart(chartData: ChartData, hitTestResult: ARHitTestResult) {
//		let builder = BarBuilder(chartData: chartData, hitTestResult: hitTestResult)
//		builder
//			.setupBars()
//			.build(at: sceneView.scene)
//	}

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

