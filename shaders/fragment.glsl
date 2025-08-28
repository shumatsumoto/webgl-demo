precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 I = gl_FragCoord.xy;
  vec4 O = vec4(u_resolution.x, u_resolution.y, u_resolution.y, 0.0);
  
  O.xy -= I + I;
  O.xy /= O.z;
  
  for (int iter = 0; iter < 52; iter++) {
    O.w = float(iter);
    if (O.w >= 52.0) break;
    O.xy *= 0.1 * mat2(6.0, 8.0, -8.0, 6.0);
    O += cos(9.0 * vec4(O.w, O.x, O.y, O.z) + u_time) / 10.0;
  }
  
  gl_FragColor = O;
}