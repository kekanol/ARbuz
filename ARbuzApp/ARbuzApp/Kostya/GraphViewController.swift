//
//  GraphViewController.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import UIKit
import SceneKit
import ARKit

final class GraphViewController: UIViewController {
	private var sceneView = ARSCNView(frame: .zero)
	private let configuration = ARWorldTrackingConfiguration()


	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .red
		sceneView.delegate = self
		configuration.planeDetection = [.vertical]
		let scene = SCNScene()
		addFloor(to: scene)
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

extension GraphViewController: ARSCNViewDelegate {

}

private extension GraphViewController {
	private func addFloor(to scene: SCNScene) {
		let floor = SCNFloor()
		floor.reflectivity = 0.5

		let material = SCNMaterial()
		material.diffuse.contents = UIImage(systemName: "chevron.left")
		material.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 0)
		// Координата текстуры S измеряет горизонтальную ось
		material.diffuse.wrapS = .repeat
		// Координата текстуры T измеряет вертикальную ось
		material.diffuse.wrapT = .repeat

		let floorNode = SCNNode(geometry: floor)
		floorNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
		floorNode.geometry?.materials = [material]

		scene.rootNode.addChildNode(floorNode)
	}
}
