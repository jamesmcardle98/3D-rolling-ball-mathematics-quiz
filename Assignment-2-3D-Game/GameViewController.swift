//
//  GameViewController.swift
//  Assignment-2-3D-Game
//
//  Created by James McArdle on 13/04/2021.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class GameViewController: UIViewController {

    let CategoryA = 2
    let CategoryB = 16
    let CategoryC = 32
    let CategoryButton = 64
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    var ballNode: SCNNode!
    var startNode: SCNNode!
    var roundNode: SCNNode!
    var selfieStickNode: SCNNode!
    
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    
    var sounds: [String:SCNAudioSource] = [:]
    var counter: Int = 0
    var score: Int = 0
    var resultsArray: [Int] = []
    var advancedResultsArray: [Double] = []
    var username: String!
    var advanced: Bool = false
    var firstTap: Bool = true
    var firstRound: Bool = true
    var gameOver: Bool = false
    
    var simpleResult: Int!
    var advancedResult: Double!
    var advancedScreen: Bool = false
    
    var soundEffect: AVAudioPlayer?
    let correctPath = Bundle.main.path(forResource: "correct.mp3", ofType: nil)!
    let incorrectPath = Bundle.main.path(forResource: "incorrect.mp3", ofType: nil)!
    
    override func viewDidLoad() {
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let welcomeScreen = UIAlertController(title: "Welcome!", message: "Please enter a Username.", preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            //Get username text field
            self.username = welcomeScreen.textFields![0].text
        })
        
        welcomeScreen.addTextField(configurationHandler: { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Type your username"
            textField.textColor = UIColor.darkText
        })
        welcomeScreen.addAction(loginAction)
        self.present(welcomeScreen, animated: true, completion: nil)
    }
    
    func resetScene() {
        firstRound = false
        setupScene()
        setupNodes()
        setupSounds()
        if (advanced){
            advancedGameLogic()
        } else {
            simpleGameLogic()
        }
        getMovement()
//        let alert = UIAlertController(title: "Error!", message: "hellp", preferredStyle: .alert)
//        //alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        self.present(alert, animated: true)
    }
    
    func getMovement() {
        let response = readLine()
        print(response)
    }
    
    func advancedGameLogic() {
        if (advancedScreen) {
            let advancedAlert = UIAlertController(title: "Welcome to Advanced!", message: "Good luck ;)", preferredStyle: .alert)
            advancedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(advancedAlert, animated: true)
            advancedScreen = false
        }
        
        if counter == 15 {
            endGame()
            gameOver = true
        }
        
        if(gameOver==false){
            counter+=1
            if let roundNode = roundNode.geometry as? SCNText {
                roundNode.string = "Round \(counter)"
            }
            let randomIntA = Int.random(in: 1..<9)
            let randomIntB = Int.random(in: 1..<9)
            let randomOperator = Int.random(in: 0..<5)
            var operation: String!
            switch randomOperator {
            case 0:
                advancedResult = Double(randomIntA + randomIntB)
                operation = "+"
            case 1:
                advancedResult = Double(randomIntA - randomIntB)
                operation = "-"
            case 2:
                advancedResult = Double(randomIntA * randomIntB)
                operation = "*"
            case 3:
                advancedResult = Double(randomIntA) / Double(randomIntB)
                advancedResult = Double(round(1000*advancedResult)/1000)
                operation = "/"
            case 4:
                advancedResult = Double(randomIntA % randomIntB)
                operation = "%"
            default:
                break
            }
            advancedResultsArray.removeAll()
            advancedResultsArray.append(advancedResult)
            advancedResultsArray.append(advancedResult + Double((Int.random(in: 1..<5))))
            advancedResultsArray.append(advancedResult + Double((Int.random(in: -5..<0))))
            
            advancedResultsArray.shuffle()
            
            let questionString = "\(randomIntA) " + operation + " \(randomIntB)?"
            
            let question = UIAlertController(title: questionString, message: "A. \(advancedResultsArray[0])      B. \(advancedResultsArray[1])      C. \(advancedResultsArray[2])", preferredStyle: .alert)
            self.present(question, animated: true)
            
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when) {
                question.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func simpleGameLogic() {
        if counter == 15 {
            endGame()
            gameOver = true
        }
        if(gameOver == false) {
            counter+=1
            if let roundNode = roundNode.geometry as? SCNText {
                roundNode.string = "Round \(counter)"
            }
            let randomIntA = Int.random(in: 0..<9)
            let randomIntB = Int.random(in: 0..<9)
            simpleResult = randomIntA + randomIntB
            
            resultsArray.removeAll()
            resultsArray.append(simpleResult)
            resultsArray.append(simpleResult + (Int.random(in: -4..<0)))
            resultsArray.append(simpleResult + (Int.random(in: 1..<4)))
            resultsArray.shuffle()
            
            let question = UIAlertController(title: "\(randomIntA) + \(randomIntB)?", message: "A. \(resultsArray[0])      B. \(resultsArray[1])      C. \(resultsArray[2])", preferredStyle: .alert)
            self.present(question, animated: true)
            
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when) {
                question.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupScene() {
        sceneView = self.view as! SCNView
        sceneView.delegate = self
        //sceneView.allowsCameraControl = true
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = scene
        
        scene.physicsWorld.contactDelegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.numberOfTapsRequired = 1
        
        tapRecognizer.addTarget(self, action: #selector(GameViewController.screenTapped(recognizer:)))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    func setupNodes() {
        ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)!
        roundNode = scene.rootNode.childNode(withName: "gameround", recursively: true)!
        ballNode.physicsBody?.contactTestBitMask = (CategoryA | CategoryB | CategoryC | CategoryButton)
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
    }
    
    func endGame(){
        let percentageCorrect = (Double(score) / Double(15)) * 100
        let percentage = String(format: "%.2f", percentageCorrect)
        let endGameAlert = UIAlertController(title: "Results for \(username!)!", message: "\n**********\n\nYou got \(score) out of 15!\n\nThat's \(percentage)% correct!", preferredStyle: .alert)
        endGameAlert.addAction(UIAlertAction(title: "Start Again!", style: .default, handler: nil))
        self.present(endGameAlert, animated: true)
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.score = 0
            self.counter = 0
            self.gameOver = false
            self.resetScene()
        }
    }
    
    func setupSounds(){
        let jumpSound = SCNAudioSource(fileNamed: "jump.wav")!
        jumpSound.load()
        jumpSound.volume = 0.8
        sounds["jump"] = jumpSound
        
        let backgroundMusic = SCNAudioSource(fileNamed: "background.mp3")!
        backgroundMusic.volume = 0.1
        backgroundMusic.loops = true
        backgroundMusic.load()
        
        let musicPlayer = SCNAudioPlayer(source: backgroundMusic)
        ballNode.addAudioPlayer(musicPlayer)
    }
    
    func calculateScore(answer: Int){
        var userAnswer: Int!
        var advancedUserAnswer: Double!
        if (advanced) {
            advancedUserAnswer = advancedResultsArray[answer]
            if advancedUserAnswer == advancedResult{
                score+=1
                let correctURL = URL(fileURLWithPath: correctPath)
                do {
                    soundEffect = try AVAudioPlayer(contentsOf: correctURL)
                    soundEffect?.play()
                } catch {
                    print("couldn't load file")
                }
            } else {
                let incorrectURL = URL(fileURLWithPath: incorrectPath)
                do {
                    soundEffect = try AVAudioPlayer(contentsOf: incorrectURL)
                    soundEffect?.play()
                } catch {
                    print("couldn't load file")
                }
            }
        } else {
            userAnswer = resultsArray[answer]
            if userAnswer == simpleResult {
                score+=1
                let correctURL = URL(fileURLWithPath: correctPath)
                do {
                    soundEffect = try AVAudioPlayer(contentsOf: correctURL)
                    soundEffect?.play()
                } catch {
                    print("couldn't load file")
                }
            } else {
                let incorrectURL = URL(fileURLWithPath: incorrectPath)
                do {
                    soundEffect = try AVAudioPlayer(contentsOf: incorrectURL)
                    soundEffect?.play()
                } catch {
                    print("couldn't load file")
                }
            }
        }
    }
    
    func startGame() {
        
        let startGameAlert = UIAlertController(title: "Mathematics Quiz for \(username!)!", message: "\n***** INSTRUCTIONS *****\n\n1. Tilt Device to Roll the Ball!\n\n2. Tap the Ball to Jump!\n\n3. Crash Into Any of the 3 Letters to Start the Quiz!\n\n4. Hit the Yellow Box to Trigger Advanced Mode! >:)\n\nEach Quiz has 15 Rounds!", preferredStyle: .alert)
        startGameAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(startGameAlert, animated: true)
        
    }
    
    @objc func screenTapped (recognizer: UITapGestureRecognizer) {
        if(firstTap) {
            startGame()
            firstTap = false
        }
        let location = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result = hitResults.first
            if let node = result?.node {
                if node.name == "ball" {
                    let jumpSound = sounds["jump"]!
                    ballNode.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
                    ballNode.physicsBody?.applyForce(SCNVector3(x: 0, y: 2.5, z: 0), asImpulse: true)
                }
                else if node.name == "floor"{
                    if location.x < 130 && location.y < 320 {
                        //go left and up
                        ballNode.physicsBody?.applyForce(SCNVector3(x: -1, y: 0, z: -1), asImpulse: true)
                    } else if location.x > 180 && location.y < 320 {
                        //right and up
                        ballNode.physicsBody?.applyForce(SCNVector3(x: 1, y: 0, z: -1), asImpulse: true)
                    } else if location.x < 130 && location.y > 320 {
                        //left and down
                        ballNode.physicsBody?.applyForce(SCNVector3(x: -1, y: 0, z: 1), asImpulse: true)
                    } else if location.x > 180 && location.y > 320 {
                        //right and down
                        ballNode.physicsBody?.applyForce(SCNVector3(x: 1, y: 0, z: 1), asImpulse: true)
                    }
                }
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        // setting this to false because this is a portrait only game
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        // no status bar
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension GameViewController: SCNSceneRendererDelegate {
    //movement of selfiestick node (above ball object) referenced from:https://github.com/brianadvent/HitTheTree/blob/master/HitTheTree/GameViewController.swift
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ball = ballNode.presentation
        let ballPosition = ball.position
        
        let targetPosition = SCNVector3(x: ballPosition.x, y: ballPosition.y + 5, z: ballPosition.z + 5)
        var cameraPosition = selfieStickNode.position
        
        let cameraDamping: Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - cameraDamping) + targetPosition.x * cameraDamping
        let yComponent = cameraPosition.y * (1 - cameraDamping) + targetPosition.y * cameraDamping
        let zComponent = cameraPosition.z * (1 - cameraDamping) + targetPosition.z * cameraDamping
        
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        selfieStickNode.position = cameraPosition
        
        motion.getAccelerometerData {(x, y, z) in
            self.motionForce = SCNVector3(x: x * 0.05, y: 0, z: (y+0.8) * -0.05)
        }
        
        ballNode.physicsBody?.velocity += motionForce
        
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
                
        if contactNode.physicsBody?.categoryBitMask == CategoryA {
            contactNode.isHidden = true
            
//            let pipeSound = sounds["pipe"]!
//            ballNode.runAction(SCNAction.playAudio(pipeSound, waitForCompletion: false))
            
            let waitAction = SCNAction.wait(duration: 0.5)
            let unhideAction = SCNAction.run { (node) in
                DispatchQueue.main.async {
                    if(!self.firstRound){
                        self.calculateScore(answer: 0)
                    }
                    self.resetScene()
                }
            }
            
            let actionSequence = SCNAction.sequence([waitAction, unhideAction])
            
            contactNode.runAction(actionSequence)
        } else if contactNode.physicsBody?.categoryBitMask == CategoryB {
            contactNode.isHidden = true
            
//            let pipeSound = sounds["pipe"]!
//            ballNode.runAction(SCNAction.playAudio(pipeSound, waitForCompletion: false))
            
            let waitAction = SCNAction.wait(duration: 0.5)
            let unhideAction = SCNAction.run { (node) in
                DispatchQueue.main.async {
                    if(!self.firstRound){
                        self.calculateScore(answer: 1)
                    }

                    self.resetScene()
                }
            }
            
            let actionSequence = SCNAction.sequence([waitAction, unhideAction])
            
            contactNode.runAction(actionSequence)
        } else if contactNode.physicsBody?.categoryBitMask == CategoryC {
            contactNode.isHidden = true
            
//            let pipeSound = sounds["pipe"]!
//            ballNode.runAction(SCNAction.playAudio(pipeSound, waitForCompletion: false))
            
            let waitAction = SCNAction.wait(duration: 0.5)
            let unhideAction = SCNAction.run { (node) in
                DispatchQueue.main.async {
                    if(!self.firstRound){
                        self.calculateScore(answer: 2)
                    }
                    self.resetScene()
                }
            }
            
            let actionSequence = SCNAction.sequence([waitAction, unhideAction])
            
            contactNode.runAction(actionSequence)
        } else if contactNode.physicsBody?.categoryBitMask == CategoryButton {
            contactNode.isHidden = true
            if (advanced) {
                advanced = false
            } else {
                advanced = true
                advancedScreen = true
                counter = 0
            }
//            let pipeSound = sounds["pipe"]!
//            ballNode.runAction(SCNAction.playAudio(pipeSound, waitForCompletion: false))
            
            let waitAction = SCNAction.wait(duration: 0.5)
            let unhideAction = SCNAction.run { (node) in
                DispatchQueue.main.async {
                    self.resetScene()
                }
            }
            
            let actionSequence = SCNAction.sequence([waitAction, unhideAction])
            
            contactNode.runAction(actionSequence)
        }
    }
}
