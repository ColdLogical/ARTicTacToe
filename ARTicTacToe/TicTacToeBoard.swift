import SceneKit

protocol TicTacToeBoardDelegate: class {
        func oWon()
        func tie()
        func xWon()
}

class TicTacToeBoard: SCNScene {
        // MARK: - Instance Variables
        weak var delegate: TicTacToeBoardDelegate?
        var numberOfMoves: Int = 0
        var winner: String?

        // MARK: - Lazy Variables
        lazy var currentSymbol: String = "X"
        lazy var symbols: [ [ String ] ] = [ [ "", "", "" ], [ "", "", "" ], [ "", "", "" ] ]
        lazy var squares: [ [ SCNNode ] ] = {
                var squaresArray: [ [ SCNNode ] ] = [ [], [], [] ]

                for row in 0...2 {
                        for column in 0...2 {
                                let square = newSquareNode()

                                let x: Float = Float(row) * 0.1
                                let y: Float = Float(column) * 0.1
                                let z: Float = 0

                                let position = simd_float3(x, y, z)
                                square.simdPosition = position

                                squaresArray[row].append(square)
                                rootNode.addChildNode(square)
                        }
                }

                return squaresArray
        }()

        // MARK: - Init Functions
        override init() {
                super.init()
                _ = squares
        }

        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Operational
        func checkForWinner() {
                var score = [ 0, 0, 0, 0, 0, 0, 0, 0 ]

                for row in 0...2 {
                        for column in 0...2 {
                                let symbol = symbols[row][column]
                                let point: Int
                                if symbol == "X" || symbol == "O" {
                                        point = symbol == "X" ? 1 : -1
                                } else {
                                        point = 0
                                }

                                score[row] += point
                                score[column + 3] += point

                                if row == column {
                                        score[6] += point
                                }

                                if (2 - column) == row {
                                        score[7] += point
                                }
                        }
                }

                var winner: String?

                for index in 0..<score.count {
                        let value = score[index]

                        if value == 3 {
                                winner = "X"
                                break
                        } else if value == -3 {
                                winner = "O"
                                break
                        }
                }

                if winner == "X" {
                        self.winner = "X"
                        delegate?.xWon()
                } else if winner == "O" {
                        self.winner = "O"
                        delegate?.oWon()
                } else if numberOfMoves == 9 {
                        self.winner = "T"
                        delegate?.tie()
                }
        }

        func newSquareNode() -> SCNNode {
                let box = SCNBox(width: 0.09, height: 0.09, length: 0.01, chamferRadius: 0)
                let square = SCNNode(geometry: box)
                return square
        }

        func newSymbolNode(on square: SCNNode, withSymbol symbol: String, andColor color: UIColor) -> SCNNode {
                // 1
                let text = SCNText(string: symbol, extrusionDepth: 0.03)
                text.font = UIFont (name: "Arial", size: 0.07)
                text.firstMaterial?.diffuse.contents = color

                // 2
                let (minVector, maxVector) = text.boundingBox
                let xOffset = (maxVector.x - minVector.x) / 2 + minVector.x
                let yOffset = (maxVector.y - minVector.y) / 2 + minVector.y
                let zOffset: Float = 0

                let symbol = SCNNode(geometry: text)
                symbol.pivot = SCNMatrix4MakeTranslation(xOffset, yOffset, zOffset)
                
                // 3
                symbol.position = square.position

                // 4
                return symbol
        }

        func tapped(on node: SCNNode) {
                guard winner == nil else {
                        return
                }

                // Find the row and column of the node that was tapped
                var row = -1
                var column = -1
                for rowIndex in 0..<squares.count {
                        for columnIndex in 0..<squares[rowIndex].count {
                                if squares[rowIndex][columnIndex] == node {
                                        row = rowIndex
                                        column = columnIndex
                                        break
                                }
                        }
                }

                guard row > -1 && column > -1 else {
                        // The node that was tapped wasn't a square on the board
                        return
                }

                guard symbols[row][column] == "" else {
                        // A move has already been played on this square
                        return
                }

                let symbol = currentSymbol

                // 1
                let symbolColor: UIColor
                if symbol == "X" {
                        symbolColor = UIColor.red
                } else {
                        symbolColor = UIColor.cyan
                }

                // 2
                let symbolNode = newSymbolNode(on: node, withSymbol: symbol, andColor: symbolColor)
                rootNode.addChildNode(symbolNode)

                symbols[row][column] = symbol
                numberOfMoves += 1
                checkForWinner()

                // 3
                if currentSymbol == "X" {
                        currentSymbol = "O"
                } else {
                        currentSymbol = "X"
                }
        }
}
