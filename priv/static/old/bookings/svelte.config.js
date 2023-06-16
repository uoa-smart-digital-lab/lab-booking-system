import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'
import { reactivePreprocess } from 'svelte-reactive-preprocessor'

export default {
  // Consult https://svelte.dev/docs#compile-time-svelte-preprocess
  // for more information about preprocessors
  preprocess: [vitePreprocess()]
}
