import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8888',
        changeOrigin: true,
        rewrite: (path) => {
          // Split path and query string
          const parts = path.split('?');
          const pathname = parts[0];
          const queryString = parts[1];
          
          // Convert /api/lessons to /backend/api/lessons.cfm
          let newPath = pathname.replace(/^\/api/, '/backend/api');
          
          // Extract the resource name (e.g., "lessons", "snippets", "groups", "students")
          const resourceMatch = newPath.match(/^\/backend\/api\/([a-zA-Z]+)/);
          
          if (resourceMatch) {
            const resource = resourceMatch[1];
            // Replace the resource with resource.cfm, removing any extra path segments
            newPath = `/backend/api/${resource}.cfm`;
          }
          
          // Re-attach query string if it exists
          if (queryString) {
            newPath += '?' + queryString;
          }
          
          console.log('Proxying:', path, '->', newPath);
          return newPath;
        },
      },
    },
  },
})
