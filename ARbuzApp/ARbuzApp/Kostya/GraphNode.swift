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
	private var timeline: SCNNode?
	private var leftline: SCNNode?
	private var scales = [SCNNode]()
	private var dates = [SCNNode]()

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
		position = SCNVector3(anchor.center.x, anchor.center.y, 0)
		converter.viewSize = CGSize(width: planeGeometry.width, height: planeGeometry.height)
		converter.viewCenter = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
		updateGraphLine()
		drawTimeLine()
		drawLeftLine()
	}

	func updateWithModels(points: [Result], name: String?) {
		converter.models = points
		updateGraphLine()
		if let name = name {
			drawTextNode(name: name)
		}
		drawScales(points)
		drawDates(points)
	}

	func updateGraphLine() {
		let path = UIBezierPath()
		guard let first = converter.points.first else { return }
		path.move(to: first)
		converter.points.forEach { path.addLine(to: $0) }
		path.close()

		let shape = SCNShape(path: path, extrusionDepth: 0.1)
		shape.firstMaterial?.fillMode = .fill
		shape.firstMaterial?.diffuse.contents = UIColor.green
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
			textNode?.position.y = Float(planeGeometry.height / 3)
			return
		}
		let node = SCNNode()
		node.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
		node.position.z += 0.05
		node.position.x = position.x
		node.position.y = position.y + Float(planeGeometry.height / 3)
		node.geometry = text
		textNode = node
		addChildNode(node)
	}

	func drawTimeLine() {
		guard timeline == nil else {
			timeline!.position.y = Float(-planeGeometry.height / 2) + 0.05
			return
		}
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.gray

		let box = SCNBox(width: 3, height: 0.1, length: 0.1, chamferRadius: 0)
		box.materials = [material]
		let node = SCNNode(geometry: box)
		node.position.z += 0.05
		node.position.x = 0
		node.position.y = Float(-planeGeometry.height / 2) - 0.05
		timeline = node

		addChildNode(node)
	}

	func drawLeftLine() {
		guard leftline == nil else {
			leftline!.position.x = Float(-planeGeometry.width / 2) - 0.05
			(leftline?.geometry as? SCNBox)?.height = planeGeometry.height
			return
		}
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.gray

		let box = SCNBox(width: 0.1, height: 2, length: 0.1, chamferRadius: 0)
		box.materials = [material]
		let node = SCNNode(geometry: box)
		node.position.z += 0.05
		node.position.x = Float(-planeGeometry.width / 2) - 0.05
		node.position.y = 0
		leftline = node

		addChildNode(node)
	}

	func drawScales(_ points: [Result]) {
		scales.forEach { $0.removeFromParentNode() }
		var newScales = [SCNNode]()
		let diff = converter.maxY - converter.minY
		let step = diff / 4

		for index in 1...4 {
			let amount = converter.minY + (Double(index) * step)
			let yPos = converter.yPos(for: amount)
			let box = SCNBox(width: planeGeometry.width, height: 0.05, length: 0.05, chamferRadius: 0)
			let material = SCNMaterial()
			material.diffuse.contents = UIColor.lightGray
			box.materials = [material]
			let node = SCNNode(geometry: box)
			node.position.x = 0
			node.position.y = Float(yPos)
			node.position.z = 0.025

			addChildNode(node)
			newScales.append(node)

			let text = SCNText(string: "\(amount.rounded())", extrusionDepth: 2)
			let textMaterial = SCNMaterial()
			textMaterial.diffuse.contents = UIColor.magenta
			text.materials = [textMaterial]
			let textNode = SCNNode(geometry: text)
			textNode.scale = SCNVector3(x:0.005, y:0.005, z:0.01)
			let height = (textNode.geometry as? SCNText)?.font.lineHeight ?? 0
			textNode.position.z = 0.05
			textNode.position.x = Float(-planeGeometry.width / 2)
			textNode.position.y = Float(yPos - height * 0.0025)

			addChildNode(textNode)
			newScales.append(textNode)
		}

		scales = newScales
	}

	func drawDates(_ points: [Result]) {
		dates.forEach { $0.removeFromParentNode() }
		var newScales = [SCNNode]()
		let diff = converter.maxX - converter.minX
		let step = diff / 6

		for index in 1...5 {
			let timeStamp = converter.minX + index * step
			let xPos = converter.xPos(for: timeStamp)
			let box = SCNBox(width: 0.05, height: 0.2, length: 0.05, chamferRadius: 0)
			let material = SCNMaterial()
			material.diffuse.contents = UIColor.lightGray
			box.materials = [material]
			let node = SCNNode(geometry: box)
			node.position.x = Float(xPos)
			node.position.y = Float(-planeGeometry.height / 2 + 0.2)
			node.position.z = 0.025

			addChildNode(node)
			newScales.append(node)

			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "dd.MM.yyyy"
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp) / 1000)
			let string = dateFormatter.string(from: date)

			let text = SCNText(string: string, extrusionDepth: 2)
			let textMaterial = SCNMaterial()
			textMaterial.diffuse.contents = UIColor.magenta
			text.materials = [textMaterial]
			let textNode = SCNNode(geometry: text)
			textNode.scale = SCNVector3(x:0.005, y:0.005, z:0.01)
			let height = (textNode.geometry as? SCNText)?.font.lineHeight ?? 0
			textNode.position.z = 0.1
			textNode.position.x =  Float(xPos)
			textNode.position.y = Float(-planeGeometry.height / 2 + height * 0.0025)

			addChildNode(textNode)
			newScales.append(textNode)
		}

		dates = newScales
	}
}
