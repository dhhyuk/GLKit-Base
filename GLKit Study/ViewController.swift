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
    
    private var SCREEN_WIDTH: CGFloat = 0, SCREEN_HEIGHT: CGFloat = 0
    
    var translateX: CGFloat = 0
    var translateY: CGFloat = 0
    var lastX : CGFloat = 0.0, lastY : CGFloat = 0.0
    
    var firstMouse : Bool = true
    
    private let quad: [Float] = [
        -10.0, -10.0,     //Left  Bottom
        10.0, -10.0,      //Right Bottom
        -10.0, 10.0,      //Left  Top
        10.0, 10.0,       //Right Top
    ]
    
    let camera : Camera = Camera()
    var program: GLuint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let glkView: GLKView = view as! GLKView
        glkView.context = EAGLContext(api: .openGLES2)
        glkView.drawableColorFormat = .RGBA8888
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        glkView.addGestureRecognizer(panGesture)
        
        EAGLContext.setCurrent(glkView.context)
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //초기 설정
    private func setup() {
        SCREEN_WIDTH = self.view.bounds.width
        SCREEN_HEIGHT = self.view.bounds.height
        
        //지정한 색으로 초기화
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        glMatrixMode(GLenum(GL_PROJECTION))
        glLoadIdentity()
        glOrthof(0.0, 480.0, 0.0, 640.0, -1.0, 1.0)
        glMatrixMode(GLenum(GL_MODELVIEW))
        glLoadIdentity()
        glViewport(0, 0, GLsizei(SCREEN_WIDTH), GLsizei(SCREEN_HEIGHT))
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        
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

    //effect.transform.modelviewMatrix = modelViewMatrix
    //effect.transform.projectionMatrix = projectionMatrix
    
    public var yaw: Float = 90.0
    public var pitch: Float = 0.0
    
    //랜더링 하는 곳
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        //glUniform2f(glGetUniformLocation(program, "translate"), GLfloat(translateX), GLfloat(translateY))
        glUniform4f(glGetUniformLocation(program, "color"), 1.0, 0.0, 0.0, 1.0)
        
        var projection = GLKMatrix4MakePerspective(camera.zoom, Float(SCREEN_WIDTH/SCREEN_HEIGHT), 0.1, 1000.0)
        var view = camera.getViewMatrix()
        
        _ = withUnsafePointer(to: &projection.m) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: MemoryLayout.size(ofValue: projection.m)) {
                glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GLboolean(GL_FALSE), $0)
            }
        }
        
        _ = withUnsafePointer(to: &view.m) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: MemoryLayout.size(ofValue: view.m)) {
                glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GLboolean(GL_FALSE), $0)
            }
        }
        
        
        
        /*//Projection    Matrix
        //fovy, aspect, zNear, zFar
        var projectionMatrix : GLKMatrix4 = GLKMatrix4MakePerspective(45.0, Float(SCREEN_WIDTH/SCREEN_HEIGHT), 0.1, 1000.0)
        
        _ = withUnsafePointer(to: &projectionMatrix.m) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: MemoryLayout.size(ofValue: projectionMatrix.m)) {
                glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GLboolean(GL_FALSE), $0)
            }
        }
        
        //ModelView     Matrix
        //let modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
        
        
        //View          Matrix
        let front = normalize(vector3(cos(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch)), sin(GLKMathDegreesToRadians(pitch)), sin(GLKMathDegreesToRadians(yaw)) * cos(GLKMathDegreesToRadians(pitch))))
        let right = normalize(cross(front, vector3(0.0, 2.0, 2.0)))
        let up = normalize(cross(right, front))
        
        var viewMatrix = GLKMatrix4MakeLookAt(front.x, front.y, front.z, right.x, right.y, right.z, up.x, up.y, up.z)
        
        
        
        _ = withUnsafePointer(to: &viewMatrix.m) {
            $0.withMemoryRebound(to: GLfloat.self, capacity: MemoryLayout.size(ofValue: viewMatrix.m)) {
                glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GLboolean(GL_FALSE), $0)
            }
        }*/
        
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}

extension ViewController {
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .ended {
            lastX = 0
            lastY = 0
            return
        }
        
        let touchLocation = recognizer.location(in: self.view)
        if lastX == 0 && lastY == 0{
            lastX = touchLocation.x
            lastY = touchLocation.y
            return
        }
        
        let xOffset = touchLocation.x - lastX
        let yOffset = lastY - touchLocation.y
        
        lastX = touchLocation.x
        lastY = touchLocation.y
        
        camera.processMouseMovement(xOffset: GLfloat(xOffset), yOffset: GLfloat(yOffset))
    }
}
