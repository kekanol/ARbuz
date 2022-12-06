//
//  GraphView.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import Foundation
import ARKit

final class GraphNode: SCNNode {

	var fixedSize = false

	private let converter = Converter()
	private var graphLineNode: SCNNode?
	private var graphLineShape: SCNShape?
	private var anchor: ARPlaneAnchor
	private var planeGeometry: SCNPlane!
	private var textNode: SCNNode?

	init(anchor: ARPlaneAnchor) {
		self.anchor = anchor
		super.init()
		configure()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Для обновления поверхности при вращении устройства
	func update(anchor: ARPlaneAnchor) {
		guard !fixedSize else { return }
		planeGeometry.width = CGFloat(anchor.extent.x) > planeGeometry.width ? CGFloat(anchor.extent.x) : planeGeometry.width
		planeGeometry.height = CGFloat(anchor.extent.z) > planeGeometry.height ? CGFloat(anchor.extent.z) : planeGeometry.height
		position = SCNVector3(anchor.center.x, anchor.center.y, 0)
		converter.viewSize = CGSize(width: planeGeometry.width, height: planeGeometry.height)
		converter.viewCenter = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
		updateGraphLine()
	}

	func updateWithModels(points: [Result], name: String?) {
		if let name = name {
			drawTextNode(name: name)
		}
		converter.models = points
		updateGraphLine()
	}

	func updateGraphLine() {
		let path = UIBezierPath()
		guard let first = converter.points.first else { return }
		path.move(to: first)
		converter.points.forEach { path.addLine(to: $0) }
		path.close()

		let shape = SCNShape(path: path, extrusionDepth: 0.1)
		shape.firstMaterial?.fillMode = .fill
		shape.firstMaterial?.diffuse.contents = UIColor.red
		graphLineShape = shape

		guard graphLineNode == nil else {
			graphLineNode?.geometry = shape
			return
		}
		graphLineNode = SCNNode(geometry: shape)
		graphLineNode!.position.z += 0.05

		addChildNode(graphLineNode!)
	}
}

private extension GraphNode {
	func configure() {
		opacity = 1

		planeGeometry = SCNPlane(
			width: 3,
			height: 2
		)

		let material = SCNMaterial()
		planeGeometry.materials = [material]
		material.diffuse.contents = UIColor.white

		geometry = planeGeometry

		position = SCNVector3(anchor.center.x, anchor.center.y, 0)
		transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1.0, 0.0, 0.0)
		updateGraphLine()
	}

	func drawTextNode(name: String) {
		let text = SCNText(string: name, extrusionDepth: 2)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.magenta
		text.materials = [material]
		guard textNode == nil else {
			textNode?.geometry = text
			return
		}
		let node = SCNNode()
		node.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
		node.position.z += 0.05
		node.position.x = position.x
		node.position.y = position.y + Float(planeGeometry.width / 3)
		node.geometry = text
		textNode = node
		addChildNode(node)
	}
}
