//
//  ViewController.swift
//  GLKit Study
//
//  Created by 김동혁 on 2017. 4. 12..
//  Copyright © 2017년 dhyuk. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    private let TAG = "ViewController"
    
    private var translateX: Float = 0
    private var translateY: Float = 0
    private let quad: [Float] = [
        -0.5, -0.5,
        0.5, -0.5,
        -0.5, 0.5,
        0.5, 0.5,
    ]
    
    var program: GLuint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let glkView: GLKView = view as! GLKView
        glkView.context = EAGLContext(api: .openGLES2)
        glkView.drawableColorFormat = .RGBA8888
        EAGLContext.setCurrent(glkView.context)
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //초기 설정
    private func setup() {
        //지정한 색으로 초기화
        glClearColor(80.0/255.0, 170.0/255.0, 80.0/255.0, 1.0)
        
        //SimpleVertexShader.glsl의 Text를 불러와 VertexShader로 컴파일
        let vertexShader = ShaderUtil.compileShader(shaderName: "SimpleVertexShader", shaderType: GLenum(GL_VERTEX_SHADER))
        
        //SimpleFragmentShader.glsl의 Text를 불러와 FragmentShader로 컴파일
        let fragmentShader = ShaderUtil.compileShader(shaderName: "SimpleFragmentShader", shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        //Program생성
        program = glCreateProgram()
        //Program에 VertexShader와 FragmentShader를 연결
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glBindAttribLocation(program, 0, "position")
        //만들어진 Program을 연결
        glLinkProgram(program)
        
        //program 결과를 가져옴
        var programLinkStatus: GLint = GL_FALSE
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &programLinkStatus)
        //GL_FALSE 실패일시 에러 로그를 출력
        if programLinkStatus == GL_FALSE {
            var programLogLength: GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &programLogLength)
            let linkLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(programLogLength))
            glGetProgramInfoLog(program, programLogLength, nil, linkLog)
            let linkLogString: NSString = NSString(utf8String: linkLog)!
            
            Log.e(TAG, "Program Link Failed! Error: \(linkLogString)")
        }
        
        //program 사용
        glUseProgram(program)
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, quad)
    }
    
    func update() {
        
    }

    //랜더링 하는 곳
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        translateX += 0.01
        translateY -= 0.005
        
        if translateX > 1 {
            translateX = -1.0
        }
        
        if translateY < -1.0 {
            translateY = 1.0
        }
        
        // TODO : Draw a triangle
        glUniform2f(glGetUniformLocation(program, "translate"), translateX, translateY)
        glUniform4f(glGetUniformLocation(program, "color"), 1.0, 0.0, 0.0, 1.0)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}

