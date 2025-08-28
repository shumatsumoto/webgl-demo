import { defineConfig } from 'vite'

export default defineConfig({
  assetsInclude: ['**/*.glsl', '**/*.vert', '**/*.frag'],
  server: {
    port: 3000,
    open: true
  }
})