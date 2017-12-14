import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

        @IBOutlet var sceneView: ARSCNView!
        @IBOutlet var statusLabel: UILabel!
        @IBOutlet var victoryView: UIView!

        var _board: TicTacToeBoard?
        var board: TicTacToeBoard {
                get {
                        if _board == nil {
                                let temp = TicTacToeBoard()
                                temp.delegate = self

                                _board = temp
                        }

                        return _board!
                }
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                sceneView.delegate = self
                sceneView.showsStatistics = true

                startNewGame()
        }

        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)

                // Startup a new session
                let configuration = ARWorldTrackingConfiguration()
                sceneView.session.run(configuration)
        }

        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                sceneView.session.pause()
        }

        // MARK: - Operational
        @IBAction func newGameTapped(sender: Any) {
                startNewGame()
        }

        func showVictory(withMessage message: String) {
                statusLabel.text = message
                victoryView.isHidden = false
        }

        func startNewGame() {
                statusLabel.text = nil
                victoryView.isHidden = true

                _board = nil
                sceneView.scene = board
        }

        // MARK: - Tap Gesture Recognizer
        @IBAction func didTap(_ recognizer: UITapGestureRecognizer) {
                let location = recognizer.location(in: sceneView)

                let options: [ SCNHitTestOption: Any ] = [
                        SCNHitTestOption.firstFoundOnly: true,
                        ]
                let sceneHitTestResults: [ SCNHitTestResult ] = sceneView.hitTest(location, options: options)
                guard let node = sceneHitTestResults.first?.node else {
                        return
                }

                board.tapped(on: node)
        }
}

extension ViewController: TicTacToeBoardDelegate {
        func oWon() {
                statusLabel.textColor = UIColor.cyan
                showVictory(withMessage: "O has WON!!!")
        }

        func tie() {
                statusLabel.textColor = UIColor.yellow
                showVictory(withMessage: "Tie Game!!")
        }

        func xWon() {
                statusLabel.textColor = UIColor.red
                showVictory(withMessage: "X has WON!!!")
        }
}
