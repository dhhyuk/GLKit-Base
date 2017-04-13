//
//  Camera.swift
//  GLKit Study
//
//  Created by 김동혁 on 2017. 4. 13..
//  Copyright © 2017년 dhyuk. All rights reserved.
//

import GLKit

class Camera {
    let YAW : GLfloat = 90.0
    let PITCH : GLfloat = 0.0
    let SPEED : GLfloat = 10.0
    let SENSITIVITY : GLfloat = 0.25
    let ZOOM : GLfloat = 45.0
    
    private var position : GLKVector3!
    private var front : GLKVector3!
    private var up : GLKVector3!
    private var right : GLKVector3!
    private var worldUp : GLKVector3!
    
    private var yaw : GLfloat = 0.0
    private var pitch : GLfloat = 0.0
    
    var movementSpeed : GLfloat = 0.0
    var mouseSensitivity : GLfloat = 0.0
    var zoom : GLfloat = 0.0
    
    public init(position : GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0)), up : GLKVector3 = GLKVector3(v: (0.0, 1.0, 0.0)), yaw : GLfloat = 90.0, pitch : GLfloat = 0.0) {
        self.position = position
        self.worldUp = up
        self.yaw = yaw
        self.pitch = pitch
        
        self.front = GLKVector3(v: (0.0, 0.0, -1.0))
        self.movementSpeed = SPEED
        self.mouseSensitivity = SENSITIVITY
        self.zoom = ZOOM
        
        self.updateCameraVectors()
    }
    
    public init(posX : GLfloat, posY : GLfloat, posZ : GLfloat, upX : GLfloat, upY : GLfloat, upZ : GLfloat, yaw : GLfloat, pitch : GLfloat) {
        self.position = GLKVector3(v: (posX, posY, posZ))
        self.worldUp = GLKVector3(v: (upX, upY, upZ))
        self.yaw = yaw
        self.pitch = pitch
        
        self.front = GLKVector3(v : (0.0, 0.0, -1.0))
        self.movementSpeed = SPEED
        self.mouseSensitivity = SENSITIVITY
        self.zoom = ZOOM
        
        self.updateCameraVectors()
    }
    
    public func getViewMatrix() -> GLKMatrix4 {
        let center = GLKVector3Add(position, front)
        
        return GLKMatrix4MakeLookAt(position.x, position.y, position.z, center.x, center.y, center.z, up.x, up.y, up.z)
    }
    
    public func processMouseMovement(xOffset : GLfloat, yOffset : GLfloat, constrainPitch : Bool = true) {
        self.yaw = self.yaw + xOffset * mouseSensitivity
        self.pitch = self.pitch + yOffset * mouseSensitivity
        
        Log.d("Camera", "yaw : \(yaw), pitch : \(pitch)")
        
        if constrainPitch {
            if self.pitch > 89.0 {
                self.pitch = 89.0
            }
            
            if self.pitch < -89.0 {
                self.pitch = -89.0
            }
        }
        
        self.updateCameraVectors()
    }
    
    private func updateCameraVectors()
    {
        var front : GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0))
        front.x = cos(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch))
        front.y = sin(GLKMathDegreesToRadians(pitch))
        front.z = sin(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch))
        self.front = GLKVector3Normalize(front)
        self.right = GLKVector3Normalize(GLKVector3CrossProduct(front, worldUp))
        self.up = GLKVector3Normalize(GLKVector3CrossProduct(right, front))
    }
}
