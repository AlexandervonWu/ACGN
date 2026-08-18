import { loader } from "@monaco-editor/react";
import * as monaco from "monaco-editor/esm/vs/editor/editor.api";
import EditorWorker from "monaco-editor/esm/vs/editor/editor.worker?worker";

let configured = false;

export function configureMonacoRuntime(): void {
  if (configured) return;
  configured = true;
  loader.config({ monaco });
  (self as typeof self & { MonacoEnvironment: { getWorker: () => Worker } }).MonacoEnvironment = {
    getWorker: () => new EditorWorker(),
  };
}
