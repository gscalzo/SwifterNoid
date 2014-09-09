//
//  GameScene.swift
//  Blocks
//
//  Created by Giordano Scalzo on 14/06/2014.
//  Copyright (c) 2014 Effective Code. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var paddle:SKNode!
    var ball:SKNode!
    
    let ballCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let brickCategory: UInt32 = 1 << 2
    let paddleCategory: UInt32 = 1 << 3
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "sunrise")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
    }
    
    func setupWorld(){
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsWorld.gravity = CGVector(dx:0, dy:0)
        self.physicsWorld.contactDelegate = self
        physicsBody!.friction = 0.0
    }
    
    func createBall() -> SKNode {
        let radius = CGFloat(20.0)
        
        let ball = SKSpriteNode(imageNamed: "ball.png")
        ball.size = CGSize(width: radius*2, height: radius*2)
        ball.position = CGPoint(x:50,y:50)
        ball.zPosition = 1
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ball.physicsBody!.dynamic = true
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.restitution = 1.0
        ball.physicsBody!.friction = 0.0
        ball.physicsBody!.linearDamping = 0.0
        ball.physicsBody!.categoryBitMask = ballCategory
        ball.physicsBody!.collisionBitMask = worldCategory | brickCategory | paddleCategory
        ball.physicsBody!.contactTestBitMask = worldCategory | brickCategory | paddleCategory
        
        return ball
    }

    func createPaddle() -> SKNode {
        let side = 120.0
        let paddle = SKShapeNode(rectOfSize: CGSize(width: side, height: side/3))
        paddle.fillColor = UIColor.blackColor()
        paddle.position = CGPoint(x: 500, y: 30)
        paddle.zPosition = 2

        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: side, height: side/3))
        paddle.physicsBody!.restitution = 0.1
        paddle.physicsBody!.friction = 0.4
        paddle.physicsBody!.dynamic = false
        paddle.physicsBody!.categoryBitMask = paddleCategory
        paddle.physicsBody!.collisionBitMask = ballCategory
        paddle.physicsBody!.contactTestBitMask = ballCategory
        return paddle
    }
    
    
    func setupBricks(){
        let side = 80
        let numBricks = 12
        let startY=600
        
        var even = true
        for row in 0...3 {
            for i in 1...numBricks {
                let brick = createBrick(side, index: i, y: startY+side*row/2, even: even)
                addChild(brick)
            }
            even = !even
        }
    }
    
    func brickColor() -> UIColor {
        let color = arc4random()%6
        
        switch color {
        case 0:
            return UIColor.greenColor()
        case 1:
            return UIColor.yellowColor()
        case 2:
            return UIColor.blueColor()
        case 3:
            return UIColor.brownColor()
        case 4:
            return UIColor.orangeColor()
        default:
            return UIColor.redColor()
        }
    }
    
    func createBrick(side: Int, index: Int, y: Int, even: Bool) -> SKNode {
        let brick = SKShapeNode(rectOfSize: CGSize(width: side, height: side/2))
        brick.fillColor = brickColor()
        
        let x = even ? index*side + side/2 : index*side
        
        brick.position = CGPoint(x: x, y: y)
        brick.zPosition = 1
        
        brick.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: side, height: side/2))
        brick.physicsBody!.dynamic = false
        brick.physicsBody!.restitution = 1.0
        brick.physicsBody!.friction = 0.0

        brick.physicsBody!.categoryBitMask = brickCategory
        brick.physicsBody!.collisionBitMask = ballCategory
        brick.physicsBody!.contactTestBitMask = ballCategory

        return brick
    }
    
    override func didMoveToView(view: SKView) {
        setupBackground()
        setupWorld()
        setupBricks()
        
        ball = createBall()
        addChild(ball)
        ball.physicsBody!.applyImpulse(CGVector(dx:10, dy:10))
        
        paddle = createPaddle()
        addChild(paddle)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch : AnyObject! = touches.anyObject()
        var location = touch.locationInNode(self)

        paddle.position.x = location.x
    }
    
    func brickFrom(contact: SKPhysicsContact) -> SKNode {
        if ( contact.bodyA.categoryBitMask & brickCategory ) == brickCategory {
           return contact.bodyA.node!
        }
        return contact.bodyB.node!
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if ( contact.bodyA.categoryBitMask & brickCategory ) == brickCategory ||
            ( contact.bodyB.categoryBitMask & brickCategory ) == brickCategory {
            let brick = brickFrom(contact)
                brick.runAction(SKAction.sequence(
                    [SKAction.scaleTo(1.5, duration:0.1),
                        SKAction.scaleTo(0.1, duration:0.3),
                        SKAction.runBlock({
                            brick.removeFromParent()
                            })
                        ]))
                
        }
        
    }
    
    
}
