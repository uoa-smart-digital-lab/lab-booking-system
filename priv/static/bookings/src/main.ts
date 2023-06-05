import './app.css'
import App from './App.svelte'

// window.addEventListener('beforeunload', function(event) {
//     // Check if the back button was pressed
//     if (performance.navigation.type === 1) {
//       console.log("HERE");
//       window.history.pushState(null, null, window.location.href);
//     }
// });

const app = new App({
  target: document.getElementById('app'),
})

export default app
