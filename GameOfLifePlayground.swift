import UIKit
import PlaygroundSupport

public enum State {
    case alive
    case dead
}

public struct Cell {
    public let x: Int
    public let y: Int
    public var state: State
    
    public init(x: Int, y: Int, state: State) {
        self.x = x
        self.y = y
        self.state = state
    }
    
    public func isNeighbor(to cell: Cell) -> Bool {
        // As we're looking for contiguous cells in XY ± 1, we can just return
        // the absolute value
        let xDelta = abs(self.x - cell.x)
        let yDelta = abs(self.y - cell.y)

        switch (xDelta, yDelta) {
        case (1, 1), (0, 1), (1, 0):
            return true
        default:
            return false
        }
    }
}

public class Grid {
    public var cells = [Cell]()
    public let size: Int
    
    public init(size: Int) {
        self.size = size
        
        for x in 0..<size {
            for y in 0..<size {
                let randomState = arc4random_uniform(3)
                // We want the cells to know their own position in the world, rather than just
                // relying on having their position determined by where they might be
                // in a nested array. This also gives performance improvements later on, as we
                // won't need to loop through a 2D array anymore when performing cell operations
                let cell = Cell(x: x, y: y, state: randomState == 0 ? .alive : .dead)
                cells.append(cell)
            }
        }
    }
    
    public func update() {
        var updatedCells = [Cell]()
        let liveCells = cells.filter { $0.state == .alive }

        for cell in cells {
            // Temporary array to get a reference to the living neighbors
            // of each cell in the loop. As we filter out dead cells, we're
            // not wasting resources looping over them
            let livingNeighbors = liveCells.filter { $0.isNeighbor(to: cell) }
            
            switch livingNeighbors.count {
            // Rule #1: If the cell is alive, and its number of neighbors
            // is 2 or 3, it lives
            case 2...3 where cell.state == .alive:
                updatedCells.append(cell)
            // Rule #2: If the cell is dead, and has 3 live neighbors,
            // it becomes alive
            case 3 where cell.state == .dead:
                let liveCell = Cell(x: cell.x, y: cell.y, state: .alive)
                updatedCells.append(liveCell)
            default:
                let deadCell = Cell(x: cell.x, y: cell.y, state: .dead)
                updatedCells.append(deadCell)
            }
        }
        cells = updatedCells
    }
}

@available(iOS 2.0, *)
public class GridView: UIView {
    var grid: Grid = Grid(size: 100)
    var cellSize: Int = 5
    
    public convenience init(gridSize: Int, cellSize: Int) {
        let frame = CGRect(x: 0, y: 0, width: gridSize * cellSize, height: gridSize * cellSize)
        self.init(frame: frame)
        self.grid = Grid(size: gridSize)
        self.cellSize = cellSize
    }
    
    public convenience init() {
        let frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        self.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        for cell in grid.cells {
          let rect = CGRect(x: cell.x * cellSize, y: cell.y * cellSize, width: cellSize, height: cellSize)
            let color = cell.state == .alive ? UIColor.white.cgColor : UIColor.black.cgColor
            context?.addRect(rect)
            context?.setFillColor(color)
            context?.fill(rect)
        }
        
        context?.restoreGState()
    }
    
    public func run() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.grid.update()
            self.setNeedsDisplay()
            self.run()
        }
    }
}

let view = GridView(gridSize: 10, cellSize: 10)
view.run()
PlaygroundPage.current.liveView = view
