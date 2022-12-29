import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vitejs.dev/config/
export default defineConfig({
  base: "/bookings/",
  mode: "development",
  plugins: [svelte()],
  resolve: {
  		dedupe: ['@fullcalendar/common'],
  	},
  optimizeDeps: {
  		include: ['@fullcalendar/common'],
  }
})
