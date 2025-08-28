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
  
  // 時間変化する歪み効果
  float time = u_time * 1.5;
  float slowTime = u_time * 0.5;
  
  // 複数の波を重ね合わせた複雑な歪み
  vec2 distortedUV = uv;
  distortedUV.x += sin(uv.y * 12.0 + time) * 0.03 * sin(slowTime);
  distortedUV.y += cos(uv.x * 9.0 + time * 1.2) * 0.025 * cos(slowTime * 0.8);
  distortedUV.x += sin(uv.y * 25.0 + time * 2.0) * 0.01;
  distortedUV.y += cos(uv.x * 18.0 + time * 1.8) * 0.015;
  
  // さらなる歪みレイヤー
  vec2 distortedUV2 = uv;
  distortedUV2.x += cos(uv.y * 8.0 - time * 0.7) * 0.02;
  distortedUV2.y += sin(uv.x * 6.0 - time * 0.9) * 0.02;
  
  // 歪んだテクスチャを取得
  vec4 distortedTexColor = texture2D(u_texture, distortedUV);
  vec4 distortedTexColor2 = texture2D(u_texture, distortedUV2);
  
  // 時間変化するカラーパターン
  vec3 pattern = abs(O.rgb) * (2.5 + 0.3 * sin(slowTime));
  
  // 時間とともに変化するカラーミックス
  float colorCycle = sin(u_time * 1.2) * 0.5 + 1.0;
  float colorCycle2 = cos(u_time * 0.8) * 0.5 + 1.0;
  float colorCycle3 = sin(u_time * 1.5 + 8.0) * 0.5 + 1.0;
  
  vec3 color1 = vec3(0.0, 0.5 + colorCycle * 0.3, 0.1); // 緑系
  vec3 color2 = vec3(0.15 + colorCycle2 * 0.1, 0.0, 0.2); // 紫系
  vec3 color3 = vec3(0.4, 0.1 + colorCycle3 * 0.15, 0.0); // オレンジ系
  
  pattern = pattern * mix(mix(color1, color2, colorCycle), color3, colorCycle2);
  
  // テクスチャのブレンド
  vec3 blendedTex = mix(distortedTexColor.rgb, distortedTexColor2.rgb, 0.3);
  
  // 時間変化する強度でエフェクトを適用
  float effectStrength = 0.5 + 0.2 * sin(u_time * 9.6);
  vec3 finalColor = blendedTex + pattern * effectStrength;
  
  gl_FragColor = vec4(finalColor, 1.0);
}