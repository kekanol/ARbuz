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
	private let network = Network()
	private var sceneView = ARSCNView(frame: .zero)
	private let configuration = ARWorldTrackingConfiguration()
	private var graph: GraphNode? {
		didSet {
			network.requestModel { [weak self] response in
				self?.graph?.updateWithModels(points: response.results)
			}
		}
	}
	private lazy var clearButton: UIButton = {
		let button = UIButton()
		button.setTitle("clear", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .white
		button.addTarget(self, action: #selector(clear), for: .touchUpInside)
		return button
	}()

	private lazy var fixedButton: UIButton = {
		let button = UIButton()
		button.setTitle("friz", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .white
		button.addTarget(self, action: #selector(freeze), for: .touchUpInside)
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		sceneView.delegate = self
		configuration.planeDetection = [.vertical]
		let scene = SCNScene()
		sceneView.scene = scene
		view.addSubview(sceneView)
		sceneView.frame = view.bounds
		sceneView.addSubview(clearButton)
		clearButton.frame = CGRect(x: 16, y: UIScreen.main.bounds.height - 66, width: 48, height: 24)

		sceneView.addSubview(fixedButton)
		fixedButton.frame = CGRect(x: 16 + 48 + 16, y: UIScreen.main.bounds.height - 66, width: 48, height: 24)
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
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		guard let uPlane = graph else {
			return
		}

		uPlane.update(anchor: anchor as! ARPlaneAnchor)
	}

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as? ARPlaneAnchor else {
			return
		}

		guard graph == nil else { return }

		let graph = GraphNode(anchor: planeAnchor)
		node.addChildNode(graph)
		self.graph = graph
	}
}

private extension GraphViewController {
	@objc func clear() {
		graph?.removeFromParentNode()
		graph = nil
	}

	@objc func freeze() {
		graph?.fixedSize = true
	}
}
