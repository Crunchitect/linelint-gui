import { createThemes } from 'tw-colors';

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    createThemes({
      light: {
        background: 'white',
        base: '#e7e5e4',
        outline: '#52525b',
        primary: 'black',
        secondary: '#78716c',
        accent: '#0ea5e9'
      }
    })
  ],
}