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

	private lazy var segmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl()
		segmentedControl.insertSegment(withTitle: "Apple", at: 0, animated: false)
		segmentedControl.insertSegment(withTitle: "Microsoft", at: 1, animated: false)
		segmentedControl.insertSegment(withTitle: "AMD", at: 2, animated: false)
		segmentedControl.insertSegment(withTitle: "Alibaba", at: 3, animated: false)
		segmentedControl.backgroundColor = .lightGray
		segmentedControl.addTarget(self, action: #selector(changeCompany), for: .valueChanged)
		return segmentedControl
	}()

	@objc
	private func changeCompany() {
		switch segmentedControl.selectedSegmentIndex {
			case 0: company = .Apple
			case 1: company = .Microsoft
			case 2: company = .AMD
			case 3: company = .Alibaba
			default: break
		}
		network.request(for: company ?? .Apple) { [weak self] response in
			self?.graph?.updateWithModels(points: response.results, name: response.ticker)
		}
	}

	private var company: Company?

	private var graph: GraphNode? {
		didSet {
			network.request(for: company ?? .Apple) { [weak self] response in
				self?.graph?.updateWithModels(points: response.results, name: response.ticker)
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
		NotificationCenter.default.addObserver(self, selector: #selector(updateGraphData), name: Notification.Name("graphDataDidUpdate"), object: nil)
		sceneView.delegate = self
		configuration.planeDetection = [.vertical]
		let scene = SCNScene()
		sceneView.scene = scene
		view.addSubview(sceneView)
		view.addSubview(segmentedControl)
		sceneView.frame = view.bounds
		segmentedControl.frame = CGRect(x: 10, y: 100, width: 350, height: 40)
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

	deinit {
		NotificationCenter.default.removeObserver(self)
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

	@objc func updateGraphData() {
		graph?.updateWithModels(points: History.shared.graphData, name: nil)
	}
}
