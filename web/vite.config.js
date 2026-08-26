import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    // Sends any /api request from the React app to the Express backend.
    proxy: { '/api': 'http://localhost:4000' },
  },
})
