//
//  ShaderUtil.swift
//  GLKit Study
//
//  Created by 김동혁 on 2017. 4. 12..
//  Copyright © 2017년 dhyuk. All rights reserved.
//

import Foundation
import GLKit

class ShaderUtil {
    
    private static let TAG = "ShaderUtil"
    
    //ShaderName(FileName)로 Shader로 Compile
    public static func compileShader(shaderName: String, shaderType: GLenum) -> GLuint {
        let shaderPath = Bundle.main.path(forResource: shaderName, ofType: "glsl")
        
        var shaderString: NSString = ""
        do {
            shaderString = try NSString(contentsOfFile: shaderPath!, encoding: String.Encoding.utf8.rawValue)
            Log.d(TAG, "CompileShader shaderString - \(shaderString)")
        } catch {}
        
        let shaderHandle = glCreateShader(shaderType)
        
        var shaderStringUTF8 = shaderString.utf8String
        //var shaderStringLength = GLint((shaderString as! String).characters.count)
        
        glShaderSource(shaderHandle, 1, &shaderStringUTF8, nil)
        
        glCompileShader(shaderHandle)
        
        var compileSuccess: GLint = GL_FALSE
        
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if compileSuccess == GL_FALSE {
            var shaderLogLength: GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &shaderLogLength)
            
            let shaderLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(shaderLogLength))
            
            glGetShaderInfoLog(shaderHandle, shaderLogLength, nil, shaderLog)
            let shaderLogString: NSString = NSString(utf8String: shaderLog)!
            
            Log.d(TAG, "Shader Compile Failed! Error: \(shaderLogString)")
        }
        
        return shaderHandle
    }
}
