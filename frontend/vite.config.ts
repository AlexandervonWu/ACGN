import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

export default defineConfig({
  base: "./",
  plugins: [react()],
  build: {
    target: "es2020",
    sourcemap: true,
    chunkSizeWarningLimit: 2400,
  },
  test: {
    environment: "jsdom",
    setupFiles: "./test/setup.tsx",
    css: true,
  },
});
