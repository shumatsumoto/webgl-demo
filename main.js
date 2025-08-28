import vertexShaderSource from './shaders/vertex.glsl?raw'
import fragmentShaderSource from './shaders/fragment.glsl?raw'

class WebGLShaderDemo {
  constructor() {
    this.canvas = document.getElementById('canvas')
    this.gl = this.canvas.getContext('webgl')
    
    if (!this.gl) {
      throw new Error('WebGL not supported')
    }
    
    this.init()
  }
  
  init() {
    this.resizeCanvas()
    window.addEventListener('resize', () => this.resizeCanvas())
    
    this.program = this.createProgram(vertexShaderSource, fragmentShaderSource)
    this.setupBuffers()
    this.loadTexture()
    
    this.startTime = Date.now()
    this.animate()
  }
  
  resizeCanvas() {
    this.canvas.width = window.innerWidth
    this.canvas.height = window.innerHeight
    this.gl.viewport(0, 0, this.canvas.width, this.canvas.height)
  }
  
  createShader(type, source) {
    const shader = this.gl.createShader(type)
    this.gl.shaderSource(shader, source)
    this.gl.compileShader(shader)
    
    if (!this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS)) {
      console.error('Shader compilation error:', this.gl.getShaderInfoLog(shader))
      this.gl.deleteShader(shader)
      return null
    }
    
    return shader
  }
  
  createProgram(vertexSource, fragmentSource) {
    const vertexShader = this.createShader(this.gl.VERTEX_SHADER, vertexSource)
    const fragmentShader = this.createShader(this.gl.FRAGMENT_SHADER, fragmentSource)
    
    const program = this.gl.createProgram()
    this.gl.attachShader(program, vertexShader)
    this.gl.attachShader(program, fragmentShader)
    this.gl.linkProgram(program)
    
    if (!this.gl.getProgramParameter(program, this.gl.LINK_STATUS)) {
      console.error('Program linking error:', this.gl.getProgramInfoLog(program))
      return null
    }
    
    return program
  }
  
  setupBuffers() {
    this.gl.useProgram(this.program)
    
    const positions = [
      -1, -1,
       1, -1,
      -1,  1,
       1,  1,
    ]
    
    const positionBuffer = this.gl.createBuffer()
    this.gl.bindBuffer(this.gl.ARRAY_BUFFER, positionBuffer)
    this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(positions), this.gl.STATIC_DRAW)
    
    const positionLocation = this.gl.getAttribLocation(this.program, 'a_position')
    this.gl.enableVertexAttribArray(positionLocation)
    this.gl.vertexAttribPointer(positionLocation, 2, this.gl.FLOAT, false, 0, 0)
    
    this.resolutionLocation = this.gl.getUniformLocation(this.program, 'u_resolution')
    this.timeLocation = this.gl.getUniformLocation(this.program, 'u_time')
    this.textureLocation = this.gl.getUniformLocation(this.program, 'u_texture')
  }
  
  loadTexture() {
    const texture = this.gl.createTexture()
    this.gl.bindTexture(this.gl.TEXTURE_2D, texture)
    
    // 一時的な1x1ピクセルのテクスチャで初期化（赤色で見やすく）
    this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, 1, 1, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE, new Uint8Array([255, 0, 0, 255]))
    
    const image = new Image()
    image.crossOrigin = 'anonymous'
    image.onload = () => {
      console.log('Image loaded successfully:', image.width, 'x', image.height)
      this.gl.bindTexture(this.gl.TEXTURE_2D, texture)
      this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image)
      
      // テクスチャパラメータを設定
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_S, this.gl.CLAMP_TO_EDGE)
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_T, this.gl.CLAMP_TO_EDGE)
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.LINEAR)
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MAG_FILTER, this.gl.LINEAR)
      
      console.log('Texture setup complete')
    }
    image.onerror = () => {
      console.error('Failed to load image: scream.png')
      console.log('Make sure scream.png is in the public directory')
    }
    image.src = './img/scream.png'
    
    this.texture = texture
  }
  
  
  animate() {
    const currentTime = (Date.now() - this.startTime) * 0.001
    
    this.gl.clearColor(0.0, 0.0, 0.0, 1.0)
    this.gl.clear(this.gl.COLOR_BUFFER_BIT)
    
    this.gl.uniform2f(this.resolutionLocation, this.canvas.width, this.canvas.height)
    this.gl.uniform1f(this.timeLocation, currentTime)
    this.gl.uniform1i(this.textureLocation, 0)
    
    this.gl.activeTexture(this.gl.TEXTURE0)
    this.gl.bindTexture(this.gl.TEXTURE_2D, this.texture)
    
    this.gl.drawArrays(this.gl.TRIANGLE_STRIP, 0, 4)
    
    requestAnimationFrame(() => this.animate())
  }
}

new WebGLShaderDemo()