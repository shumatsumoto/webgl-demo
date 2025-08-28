precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D u_texture;

void main() {
  vec2 I = gl_FragCoord.xy;
  vec2 uv = I / u_resolution.xy;
  uv.y = 1.0 - uv.y; // Y軸を反転
  
  // まずはテクスチャをそのまま表示
  vec4 texColor = texture2D(u_texture, uv);
  
  // テクスチャが読み込まれていない場合のフォールバック（赤色）
  if (texColor.rgb == vec3(1.0, 0.0, 0.0)) {
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // 赤色表示
    return;
  }
  
  // 元のShadertoyエフェクト（軽量版）
  vec4 O = vec4(u_resolution.x, u_resolution.y, u_resolution.y, 0.0);
  O.xy -= I + I;
  O.xy /= O.z;
  
  for (int iter = 0; iter < 20; iter++) { // ループを軽量化
    O.w = float(iter);
    if (O.w >= 20.0) break;
    O.xy *= 0.1 * mat2(6.0, 8.0, -8.0, 6.0);
    O += cos(9.0 * vec4(O.w, O.x, O.y, O.z) + u_time) / 20.0;
  }
  
  // 軽い歪み効果
  float time = u_time * 2.5;
  vec2 distortedUV = uv;
  distortedUV.x += sin(uv.y * 10.0 + time) * 0.02;
  distortedUV.y += cos(uv.x * 8.0 + time) * 0.02;
  
  // 歪んだテクスチャを取得
  vec4 distortedTexColor = texture2D(u_texture, distortedUV);
  
  // シンプルなブレンディング - 緑を強く
  vec3 pattern = abs(O.rgb) * 0.7;
  pattern = pattern * vec3(0.0, .5, 0.0);
  vec3 finalColor = distortedTexColor.rgb + pattern;
  
  gl_FragColor = vec4(finalColor, 1.0);
}