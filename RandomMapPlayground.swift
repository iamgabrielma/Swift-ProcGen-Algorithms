import UIKit
import PlaygroundSupport
import simd

let mapWidth: Int32 = 40
let mapHeight: Int32 = 40
var tileSize: Int = 10
var mapString: String = ""
var mapNodes: [SIMD2<Int32>: String] = [:]

struct Node: Hashable {
    let gridPosition: SIMD2<Int32>
}

struct Rectangle {
    let start: SIMD2<Int32>
    var w: Int32
    var h: Int32
}

final class Grid {
    
    func makeRoom(at startPosition: SIMD2<Int32>) {
        let roomSize: Int32 = 5
        var rectangle = Rectangle(
            start: startPosition,
            w: (startPosition.x + roomSize),
            h: (startPosition.y + roomSize)
        )
        // Out-of-bounds check. Clips the size of the room
        // to the max size of the underlying map
        if (startPosition.x + roomSize >= mapWidth) {
            let difference = mapWidth - (startPosition.x + roomSize)
            rectangle.w -= difference
        }
        if (startPosition.y + roomSize >= mapHeight) {
            let difference = mapHeight - (startPosition.y + roomSize)
            rectangle.h -= difference
        }
        
        for x in startPosition.x..<rectangle.w {
            for y in startPosition.y..<rectangle.h {
                let node = Node(gridPosition: SIMD2<Int32>(x,y))
                mapNodes.updateValue(".", forKey: node.gridPosition)
            }
        }
    }

    // MAKE FLOOR
    func makeFloor() {
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                let node = Node(gridPosition: SIMD2<Int32>(x,y))
                mapNodes.updateValue("#", forKey: node.gridPosition)
            }
        }
    }

    // MAKE BOUNDARIES
    func makeBoundaries() {
        var position = SIMD2<Int32>(0,0)
        // Upper boundary
        for key in mapNodes.keys {
            position.x = key.x
            mapNodes[position] = "#"
        }
        // Lower boundary
        for key in mapNodes.keys {
            position.x = key.x
            position.y = mapHeight - 1
            mapNodes[position] = "#"
        }
        // Left boundary
        for key in mapNodes.keys {
            position.x = 0
            position.y = key.y
            mapNodes[position] = "#"
        }
        // Right boundary
        for key in mapNodes.keys {
            position.x = mapWidth - 1
            position.y = key.y
            mapNodes[position] = "#"
        }
    }

    // RENDER NODES
    func renderMap() {
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                let position = SIMD2<Int32>(x,y)
                if let nodeFound = mapNodes[position] {
                    mapString.append(nodeFound)
                }
            }
            mapString.append("\n")
        }
    }

    // BUILD MAP
    func buildBaseMap(numberOfRooms: Int){
        makeFloor()
        
        for _ in 0..<numberOfRooms {
            let randX = Int32.random(in: 0..<mapWidth)
            let randY = Int32.random(in: 0..<mapHeight)
            makeRoom(at: SIMD2<Int32>(randX,randY))
        }
        makeBoundaries()
        renderMap()
        print("Nodes: \(mapNodes.count)")
        print(mapString)
    }
}

final class DisplayView: UIView {
    convenience init() {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: Int(mapWidth) * tileSize,
            height: Int(mapHeight) * tileSize
        )
        self.init(frame: frame)
        
        let grid = Grid()
        grid.buildBaseMap(numberOfRooms: 10)
    }
    
    override func draw(_ rect: CGRect) {
        // Reference to Core Graphics CGContext
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // Core Graphics & UIView draw() method:
        // We're passing the drawing instructions to CGContext, telling it what to draw for every node
        for node in mapNodes {
            let rectangle = CGRect(
                x: Int(node.key.x) * tileSize,
                y: Int(node.key.y) * tileSize,
                width: tileSize,
                height: tileSize
            )
            let color = node.value == "." ? UIColor.white.cgColor : UIColor.black.cgColor
            context?.addRect(rectangle)
            context?.setFillColor(color)
            context?.fill(rectangle)
        }
        // Set the CGContext changes, so that they can appear in the view
        context?.restoreGState()
    }
}

let view = DisplayView()
PlaygroundPage.current.liveView = view
