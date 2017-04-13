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
    var tempX: CGFloat = 0.0, tempY: CGFloat = 0.0
    private let quad: [Float] = [
        -10.5, -10.25,     //Left  Bottom
        10.5, -10.25,      //Right Bottom
        -10.5, 10.25,      //Left  Top
        10.5, 10.25,       //Right Top
    ]
    
    var effect: GLKBaseEffect!
    
    var program: GLuint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let glkView: GLKView = view as! GLKView
        glkView.context = EAGLContext(api: .openGLES2)
        glkView.drawableColorFormat = .RGBA8888
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        glkView.addGestureRecognizer(panGesture)
        
        EAGLContext.setCurrent(glkView.context)
        
        effect = GLKBaseEffect()
        
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
        glClearColor(80.0/255.0, 170.0/255.0, 80.0/255.0, 1.0)
        
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
        
        
        //Projection    Matrix
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
        }
        
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}

extension ViewController {
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .ended {
            //Log.d("ViewController", "Gesture Ended")
            tempX = 0
            tempY = 0
            return
        }
        let touchLocation = recognizer.location(in: self.view)
        
        if tempX == 0 && tempY == 0{
            tempX = touchLocation.x//self.view.bounds.width
            tempY = touchLocation.y//self.view.bounds.height * -1
            return
        }
        
        translateX = translateX + (touchLocation.x - tempX) * 2/self.view.bounds.width
        translateY = translateY + (touchLocation.y - tempY) * 2/self.view.bounds.height * -1
        
        yaw = yaw + Float(translateX)
        //pitch = pitch + Float(translateY)
        Log.d("ViewController", "yaw : \(yaw) , pitch : \(pitch)")
        
        tempX = touchLocation.x
        tempY = touchLocation.y
        
        
        
        //translateX = touchPoint.x/self.view.bounds.width
        //translateY = touchPoint.y/self.view.bounds.height * -1
        //Log.d("ViewController", "Touch Location : \(touchLocation), Translate (\(translateX), \(translateY))")
    }
}
