import UIKit
import Foundation

let view = UIView

DispatchQueue.global(qos: .background).async {
	view.layer.backgroundColor = UIColor.red.cgColor // УПАДЕТ потому что идет обращение к UIView
}

let layer = CALayer()
view.layer.addSublayer(layer)
layer.frame = view.bounds

DispatchQueue.global(qos: .background).async {
	layer.backgroundColor = UIColor.red.cgColor // НЕ УПАДЕТ потому что идет обращение к CALayer аа его можно менять с любого потока
	
}
