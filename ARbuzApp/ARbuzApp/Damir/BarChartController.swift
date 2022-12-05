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

		let colorTexture = UIColor.red

		// Создаем сцену
		let scene = SCNScene()

		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
		configuration.planeDetection = [.horizontal, .vertical]

//		addNewCubeModel(
//			size: 0.2,
//			position: SCNVector3(0, 0, -1.0),
//			texture: colorTexture,
//			scene: scene
//		)

//        addNewCubeModel(
//            size: 0.2,
//            position: SCNVector3(0, 0, -1.0),
//            texture: imageTexture,
//            scene: scene
//        )

//        addNewTextModel(
//            text: "Mad Box",
//            scale: SCNVector3(0.005, 0.005, 0.005),
//            position: SCNVector3(-0.2, 0.3, -1.0),
//            depth: 3.0,
//            color: .orange,
//            scene: scene
//        )
//
//        addNewModel(
//            withPath: "art.scnassets/dance/dance.dae",
//            scale: SCNVector3(0.07, 0.07, 0.07),
//            position: SCNVector3(-0.25, -0.1, -1.0),
//            scene: scene
//        )
//
//        addNewModel(
//            withPath: "art.scnassets/dance/dance.dae",
//            scale: SCNVector3(0.07, 0.07, 0.07),
//            position: SCNVector3(0.25, -0.1, -1.0),
//            scene: scene
//        )
//
//        addNewModel(
//            withPath: "art.scnassets/dance/dance.dae",
//            scale: SCNVector3(0.07, 0.07, 0.07),
//            position: SCNVector3(0, -0.1, -1.5),
//            scene: scene
//        )

		//addFloor(to: scene)
		//configureTapGesture()
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

	private func getCubeNode(size: CGFloat, position: SCNVector3, texture: Any?) -> SCNNode {
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

	private func addNewCubeModel(size: CGFloat, position: SCNVector3, texture: Any?, scene: SCNScene) {
		let node = getCubeNode(size: size, position: position, texture: texture)
		scene.rootNode.addChildNode(node)
	}

	private func addNewTextModel(text: String, scale: SCNVector3, position: SCNVector3, depth: CGFloat, color: UIColor, scene: SCNScene) {
		let textGeometry = SCNText(string: text, extrusionDepth: depth)

		let textMaterial = SCNMaterial()
		textMaterial.diffuse.contents = color

		let textNode = SCNNode(geometry: textGeometry)
		textNode.scale = scale
		textNode.geometry?.materials = [textMaterial]
		textNode.position = position

		scene.rootNode.addChildNode(textNode)
	}

	private func addNewModel(withPath: String, scale: SCNVector3, position: SCNVector3, scene: SCNScene) {
		let node = SCNNode()

		guard let loadedScene = SCNScene(named: withPath) else {
			return
		}

		loadedScene.rootNode.childNodes.forEach {
			node.addChildNode($0 as SCNNode)
		}

		node.scale = scale
		node.position = position

		scene.rootNode.addChildNode(node)
	}

}

extension BarChartController: ARSCNViewDelegate {

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as? ARPlaneAnchor else {
			return
		}

		let plane = Plane(anchor: planeAnchor)

		planes.append(plane)
		node.addChildNode(plane)
	}

	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		let plane = planes.filter {
			$0.anchor.identifier == anchor.identifier
		}.first

		guard let uPlane = plane else {
			return
		}

		uPlane.update(anchor: anchor as! ARPlaneAnchor)
	}

}

extension BarChartController: ARSessionDelegate {

	func session(_ session: ARSession, didFailWithError error: Error) {
	}

	func session(_ session: ARSession, didUpdate frame: ARFrame) {
	}
}

