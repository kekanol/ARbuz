//
//  GraphView.swift
//  ARbuzApp
//
//  Created by Емельянов Константин Станиславович on 05.12.2022.
//

import Foundation
import ARKit

final class GraphNode: SCNNode {

	private let converter = Converter()
	var fixedSize = false
	var graphLineNode: SCNNode?
	var graphLineShape: SCNShape?

	var anchor: ARPlaneAnchor
	var planeGeometry: SCNPlane!

	init(anchor: ARPlaneAnchor) {
		self.anchor = anchor
		super.init()
		configure()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configure() {
		opacity = 1

		planeGeometry = SCNPlane(
			width: 2.5,
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

	func updateWithModels(points: [Result]) {
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
