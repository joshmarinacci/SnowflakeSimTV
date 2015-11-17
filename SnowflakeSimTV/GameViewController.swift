//
//  GameViewController.swift
//  SnowflakeSimTV
//
//  Created by Josh Marinacci on 11/12/15.
//  Copyright (c) 2015 Josh Marinacci. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var scene:SCNScene = SCNScene()
    
    var redButton   = UIButton(type: UIButtonType.System)
    var blackButton = UIButton(type: UIButtonType.System)
    var blueButton  = UIButton(type: UIButtonType.System)

    var breezyButton    = UIButton(type: UIButtonType.System)
    var blusteryButton  = UIButton(type: UIButtonType.System)
    var blizzardButton  = UIButton(type: UIButtonType.System)

    override func viewDidLoad() {
        super.viewDidLoad()

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        scene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        //        scene.rootNode.addChildNode(lightNode)
        
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.whiteColor()
        scene.rootNode.addChildNode(ambientLightNode)

        let part = Particle.init(gvc: self, x:0,y:0,z:0, rotationTime: 3, image:images[0])
        scene.rootNode.addChildNode(part.planeNode)
        
        let scnView = self.view as! SCNView

        scnView.delegate = self
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
//        scnView.backgroundColor = UIColor.redColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        var gestureRecognizers = [UIGestureRecognizer]()
        gestureRecognizers.append(tapGesture)
        if let existingGestureRecognizers = scnView.gestureRecognizers {
            gestureRecognizers.appendContentsOf(existingGestureRecognizers)
        }
        scnView.gestureRecognizers = gestureRecognizers
        
        
        
        redButton.setTitle("red/white", forState: UIControlState.Normal)
        redButton.frame = CGRectMake(100, 100, 400, 100)
        scnView.addSubview(redButton)

        blackButton.setTitle("black/white", forState: UIControlState.Normal)
        blackButton.frame = CGRectMake(600, 100, 400, 100)
        scnView.addSubview(blackButton)

        blueButton.setTitle("white/blue", forState: UIControlState.Normal)
        blueButton.frame = CGRectMake(1100, 100, 400, 100)
        scnView.addSubview(blueButton)

        breezyButton.setTitle("Breezy", forState: UIControlState.Normal)
        breezyButton.frame = CGRectMake(100, 300, 400, 100)
        scnView.addSubview(breezyButton)
        
        blusteryButton.setTitle("Blustery", forState: UIControlState.Normal)
        blusteryButton.frame = CGRectMake(600, 300, 400, 100)
        scnView.addSubview(blusteryButton)
        
        blizzardButton.setTitle("Blizzardy", forState: UIControlState.Normal)
        blizzardButton.frame = CGRectMake(1100, 300, 400, 100)
        scnView.addSubview(blizzardButton)
    
        
//        scene.background.contents = UIColor(hue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
//        scene.background.contents = UIColor.brownColor()
  //      scnView.backgroundColor = UIColor.brownColor()
        scnView.backgroundColor = UIColor(hue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    
    
    let MAX_COUNT = 100
    let EMIT_PERIOD = 0.2
    let START_Y:Float = 15
    let END_Y:Float = -15
    let FALL_DURATION:CFTimeInterval = 20
    let BASE_SIZE:CGFloat = 2.0
    var FLAKE_COLOR = UIColor.blueColor()
    var MASTER_SPEED:Float = 5.0
    let images = [
        UIImage(imageLiteral: "snowflake0.png"),
        UIImage(imageLiteral: "snowflake1.png"),
        UIImage(imageLiteral: "snowflake2.png"),
        UIImage(imageLiteral: "snowflake3.png"),
        UIImage(imageLiteral: "snowflake4.png"),
        UIImage(imageLiteral: "snowflake5.png"),
        UIImage(imageLiteral: "snowflake6.png"),
        UIImage(imageLiteral: "snowflake7.png"),
        UIImage(imageLiteral: "snowflake8.png")
    ]
    
    var particles:NSMutableArray = []
    
    class Particle: NSObject {
        var gvc:GameViewController
        var planeNode:SCNNode
        var planeGeometry:SCNPlane
        var x:Float
        var y:Float
        var z:Float
        var material:SCNMaterial
        
        internal init(gvc:GameViewController, x:Float, y:Float, z:Float, rotationTime:CFTimeInterval, image:UIImage) {
            self.gvc = gvc
            
            planeGeometry = SCNPlane(width: gvc.BASE_SIZE, height: gvc.BASE_SIZE)
            planeNode = SCNNode(geometry: planeGeometry)
            self.x = x;
            self.y = y;
            self.z = z;
            self.material = SCNMaterial()

            super.init()
            
            planeNode.rotation = SCNVector4(x:0, y:1, z:0, w:0)
            
            material.doubleSided = true
            material.multiply.contents = gvc.FLAKE_COLOR
            material.diffuse.contents = image
            material.blendMode = SCNBlendMode.Alpha
            
            planeGeometry.firstMaterial = material
            planeNode.position = SCNVector3(x:x,y:gvc.START_Y,z:z)
            
            let verticalAnimation = CABasicAnimation(keyPath: "position")
            verticalAnimation.fromValue = NSValue(SCNVector3: SCNVector3(x:x,y:gvc.START_Y,z:z))
            verticalAnimation.toValue = NSValue(SCNVector3: SCNVector3(x:x,y:gvc.END_Y,z:z))
            verticalAnimation.duration = gvc.FALL_DURATION
            verticalAnimation.autoreverses = false
            verticalAnimation.speed = gvc.MASTER_SPEED
            verticalAnimation.repeatCount = 1
            verticalAnimation.delegate = self
            verticalAnimation.setValue("position", forKey:"animationName")
            planeNode.addAnimation(verticalAnimation, forKey: "position")
            
            let axisAnimation = CABasicAnimation(keyPath: "rotation")
            axisAnimation.fromValue = NSValue(SCNVector4: SCNVector4(x: 0, y: 1, z: 0, w:self.d2r(0)))
            axisAnimation.toValue = NSValue(SCNVector4: SCNVector4(x: 0, y: 1, z: 0, w:self.d2r(360)))
            axisAnimation.duration = rotationTime
            axisAnimation.speed = gvc.MASTER_SPEED
            axisAnimation.autoreverses = false
            axisAnimation.repeatCount = Float.infinity
            planeNode.addAnimation(axisAnimation, forKey: "rotation")
        }
        
        func d2r (inp: Float) -> Float {
            return inp*3.1457/180.0
        }

        func restartAnim() {
            //update flake color
            material.multiply.contents = gvc.FLAKE_COLOR
            
            let verticalAnimation          = CABasicAnimation(keyPath: "position")
            verticalAnimation.fromValue    = NSValue(SCNVector3: SCNVector3(x:x,y:gvc.START_Y,z:z))
            verticalAnimation.toValue      = NSValue(SCNVector3: SCNVector3(x:x,y:gvc.END_Y,z:z))
            verticalAnimation.duration     = gvc.FALL_DURATION
            verticalAnimation.autoreverses = false
            verticalAnimation.speed        = gvc.MASTER_SPEED
            verticalAnimation.repeatCount  = 1
            verticalAnimation.delegate     = self
            verticalAnimation.setValue("position", forKey:"animationName")
            planeNode.addAnimation(verticalAnimation, forKey: "position")
            print("restarting animation")
        }
        
        override func animationDidStart(_anim: CAAnimation) {
        }
        override func animationDidStop(_anim: CAAnimation, finished flag: Bool) {
            self.restartAnim()
        }
    }
    
    
    var starttime:NSTimeInterval = -1
    var prevtime:NSTimeInterval = -1
    var lastsec = -1
    var count = 0
    
    func randi(firstNum: Int, _ secondNum: Int) -> Int {
        let rand = Int(arc4random_uniform(UInt32(secondNum-firstNum)))
        return rand + firstNum
    }
    func randf(firstNum: Float, _ secondNum: Float) -> Float{
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        if(starttime == -1) {
            starttime = time;
            prevtime = time
            return;
        }
        
        //        let diff = time - starttime
        let tdiff = time - prevtime
        var ediff = time - starttime
        if(tdiff > EMIT_PERIOD && count < MAX_COUNT) {
            prevtime = time
            let x = randf(-10, 10)
            let y:Float = -15
            
            let part = Particle.init(
                gvc: self,
                x:x,
                y:y,
                z:randf(-3,10),
                rotationTime: CFTimeInterval(randf(3,5)),
                image:images[randi(0,images.count)])
                particles.addObject(part)
            scene.rootNode.addChildNode(part.planeNode)
            count++
        }
        
        let scnView = self.view as! SCNView
        
        scnView.backgroundColor = UIColor(hue: CGFloat(ediff/10), saturation: 1, brightness: 1, alpha: 1)
        
    }

    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
/*        print("tapped");
        UIView.animateWithDuration(1.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.redButton.alpha = 0
        }, completion: nil)
        redButton.alpha = 0
*/
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        let scnView = self.view as! SCNView
        if(context.nextFocusedView == redButton) {
//            scnView.backgroundColor = UIColor.redColor()
//            FLAKE_COLOR = UIColor.whiteColor()
        }
        if(context.nextFocusedView == blackButton) {
//            scnView.backgroundColor = UIColor.blackColor()
            FLAKE_COLOR = UIColor.redColor()
        }
        if(context.nextFocusedView == blueButton) {
//            scnView.backgroundColor = UIColor.blueColor()
            FLAKE_COLOR = UIColor.blackColor()
            
            
        }
        if(context.nextFocusedView == breezyButton) {
            MASTER_SPEED = 1.0
        }
        if(context.nextFocusedView == blusteryButton) {
            MASTER_SPEED = 3.0
        }
        if(context.nextFocusedView == blizzardButton) {
            MASTER_SPEED = 10.0
        }

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
