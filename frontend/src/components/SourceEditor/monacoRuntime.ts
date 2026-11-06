import { loader } from "@monaco-editor/react";
import * as monaco from "monaco-editor/editor/editor.api.js";
import EditorWorker from "monaco-editor/editor/editor.worker.js?worker";

let configured = false;

export function configureMonacoRuntime(): void {
  if (configured) return;
  configured = true;
  loader.config({ monaco });
  (self as typeof self & { MonacoEnvironment: { getWorker: () => Worker } }).MonacoEnvironment = {
    getWorker: () => new EditorWorker(),
  };
}
