import { useEffect, useRef, useState } from "react";
import Editor, { type BeforeMount, type Monaco, type OnMount } from "@monaco-editor/react";
import type { editor } from "monaco-editor/esm/vs/editor/editor.api";
import { FileUp } from "lucide-react";
import type { Diagnostic, SourceMapping } from "../../api/types";
import {
  mappingsAtPosition,
  mappingsForEntities,
  mappingsForEntity,
  toMonacoRange,
} from "../../utils/sourceRanges";
import { IconButton } from "../Common/IconButton";
import { PanelHeader } from "../Common/PanelHeader";

const editorRuntime = import.meta.env.MODE === "test"
  ? Promise.resolve()
  : import("./monacoRuntime").then(({ configureMonacoRuntime }) => configureMonacoRuntime());

interface SourceEditorProps {
  model: string;
  diagnostics: Diagnostic[];
  mappings: SourceMapping[];
  selectedEClassId?: string;
  selectedENodeId?: string;
  slotEntityIds: string[];
  ambiguousMappingIds: string[];
  inspecting: boolean;
  onChange: (model: string) => void;
  onAnalyze: () => void;
  onMappingsSelected: (mappings: SourceMapping[]) => void;
  onMappingSelected: (mapping: SourceMapping) => void;
}

const configureAlloy: BeforeMount = (monaco) => {
  if (!monaco.languages.getLanguages().some((language) => language.id === "alloy")) {
    monaco.languages.register({ id: "alloy", extensions: [".als"] });
    monaco.languages.setMonarchTokensProvider("alloy", {
      keywords: [
        "abstract", "all", "and", "as", "assert", "but", "check", "disj",
        "else", "exactly", "extends", "fact", "for", "fun", "iden", "iff",
        "implies", "in", "Int", "let", "lone", "module", "no", "none", "not",
        "one", "open", "or", "pred", "run", "set", "sig", "some", "sum", "univ",
      ],
      operators: ["=", "!=", "=>", "<=>", "->", ".", "+", "-", "&", "#", "~", "^", "*", "|", ":"],
      tokenizer: {
        root: [
          [/\/\*/, "comment", "@comment"],
          [/--.*$/, "comment"],
          [/[a-zA-Z_$][\w$]*/, { cases: { "@keywords": "keyword", "@default": "identifier" } }],
          [/\d+/, "number"],
          [/"([^"\\]|\\.)*$/, "string.invalid"],
          [/"/, "string", "@string"],
          [/[{}()[\]]/, "@brackets"],
          [/[<>=!+\-*&|:#.~^]+/, "operator"],
        ],
        comment: [
          [/[^/*]+/, "comment"],
          [/\/\*/, "comment", "@push"],
          ["\\*/", "comment", "@pop"],
          [/[/*]/, "comment"],
        ],
        string: [
          [/[^\\"]+/, "string"],
          [/\\./, "string.escape"],
          [/"/, "string", "@pop"],
        ],
      },
    });
    monaco.editor.defineTheme("alloy-explorer", {
      base: "vs",
      inherit: true,
      rules: [
        { token: "keyword", foreground: "0F6B67", fontStyle: "bold" },
        { token: "operator", foreground: "7A4A0B" },
        { token: "comment", foreground: "738078", fontStyle: "italic" },
        { token: "number", foreground: "8250A8" },
      ],
      colors: {
        "editor.background": "#FBFCFD",
        "editorLineNumber.foreground": "#98A1AA",
        "editorLineNumber.activeForeground": "#33404D",
        "editor.selectionBackground": "#B8DAD7AA",
        "editor.lineHighlightBackground": "#F1F5F6",
        "editorIndentGuide.background1": "#E5E9ED",
      },
    });
  }
};

export function SourceEditor({
  model,
  diagnostics,
  mappings,
  selectedEClassId,
  selectedENodeId,
  slotEntityIds,
  ambiguousMappingIds,
  inspecting,
  onChange,
  onAnalyze,
  onMappingsSelected,
  onMappingSelected,
}: SourceEditorProps) {
  const editorRef = useRef<editor.IStandaloneCodeEditor>();
  const monacoRef = useRef<Monaco>();
  const decorationsRef = useRef<editor.IEditorDecorationsCollection>();
  const inputRef = useRef<HTMLInputElement>(null);
  const analyzeRef = useRef(onAnalyze);
  const [runtimeState, setRuntimeState] = useState<"loading" | "ready" | "error">(
    import.meta.env.MODE === "test" ? "ready" : "loading",
  );
  const mappingsRef = useRef(mappings);
  const mappingsSelectedRef = useRef(onMappingsSelected);
  analyzeRef.current = onAnalyze;
  mappingsRef.current = mappings;
  mappingsSelectedRef.current = onMappingsSelected;

  useEffect(() => {
    if (runtimeState !== "loading") return;
    let active = true;
    void editorRuntime.then(
      () => { if (active) setRuntimeState("ready"); },
      () => { if (active) setRuntimeState("error"); },
    );
    return () => { active = false; };
  }, [runtimeState]);

  const mount: OnMount = (instance, monaco) => {
    editorRef.current = instance;
    monacoRef.current = monaco;
    instance.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter, () => analyzeRef.current());
    instance.onMouseDown((event) => {
      const position = event.target.position;
      if (!position) return;
      mappingsSelectedRef.current(mappingsAtPosition(mappingsRef.current, {
        line: position.lineNumber,
        column: position.column,
      }));
    });
  };

  useEffect(() => {
    const instance = editorRef.current;
    if (!instance) return;
    const selectedMappings = [...new Map([
      ...mappingsForEntity(mappings, selectedEClassId, selectedENodeId),
      ...mappingsForEntities(mappings, slotEntityIds),
    ].map((mapping) => [mapping.id, mapping])).values()];
    decorationsRef.current?.clear();
    decorationsRef.current = instance.createDecorationsCollection(selectedMappings.map((mapping, index) => ({
      range: toMonacoRange(mapping.sourceRange),
      options: {
        className: index === 0 ? "source-mapping-primary" : "source-mapping-secondary",
        isWholeLine: false,
        hoverMessage: { value: `${mapping.kind}: ${mapping.id}` },
        overviewRuler: {
          color: index === 0 ? "#138A84" : "#D59028",
          position: 2,
        },
      },
    })));
    if (selectedMappings[0]) {
      const range = toMonacoRange(selectedMappings[0].sourceRange);
      instance.revealRangeInCenterIfOutsideViewport(range);
    }
  }, [mappings, selectedEClassId, selectedENodeId, slotEntityIds]);

  useEffect(() => {
    const instance = editorRef.current;
    const editorModel = instance?.getModel();
    if (!instance || !editorModel) return;
    const monaco = monacoRef.current;
    if (!monaco) return;
    monaco.editor.setModelMarkers(editorModel, "analysis-backend", diagnostics.map((diagnostic) => ({
      ...(diagnostic.sourceRange ? toMonacoRange(diagnostic.sourceRange) : {
        startLineNumber: 1,
        startColumn: 1,
        endLineNumber: 1,
        endColumn: 1,
      }),
      message: diagnostic.message,
      severity: diagnostic.severity === "error"
        ? monaco.MarkerSeverity.Error
        : diagnostic.severity === "warning"
          ? monaco.MarkerSeverity.Warning
          : monaco.MarkerSeverity.Info,
      code: diagnostic.code,
    })));
  }, [diagnostics]);

  const ambiguous = mappings.filter((mapping) => ambiguousMappingIds.includes(mapping.id));

  return (
    <section className="workspace-panel source-panel" aria-label="Alloy source">
      <PanelHeader
        title="Source"
        actions={(
          <>
            {inspecting && <span className="panel-activity">Inspecting</span>}
            <IconButton label="Open Alloy file" onClick={() => inputRef.current?.click()}>
              <FileUp size={15} />
            </IconButton>
            <input
              ref={inputRef}
              hidden
              type="file"
              accept=".als,text/plain"
              onChange={(event) => {
                const file = event.target.files?.[0];
                if (file) void file.text().then(onChange);
                event.currentTarget.value = "";
              }}
            />
          </>
        )}
      />
      <div className="editor-shell">
        {runtimeState === "ready" ? <Editor
          height="100%"
          language="alloy"
          theme="alloy-explorer"
          value={model}
          beforeMount={configureAlloy}
          onMount={mount}
          onChange={(value) => onChange(value ?? "")}
          options={{
            automaticLayout: true,
            minimap: { enabled: false },
            fontFamily: "JetBrains Mono, Cascadia Code, Consolas, monospace",
            fontSize: 13,
            lineHeight: 20,
            lineNumbersMinChars: 3,
            padding: { top: 10 },
            scrollBeyondLastLine: false,
            wordWrap: "off",
            tabSize: 2,
            renderWhitespace: "selection",
            overviewRulerBorder: false,
            fixedOverflowWidgets: true,
          }}
        /> : (
          <div className="empty-panel">
            {runtimeState === "error" ? "Editor runtime could not be loaded" : "Loading editor runtime"}
          </div>
        )}
      </div>
      {ambiguous.length > 1 && (
        <div className="mapping-chooser" role="status">
          <span>{ambiguous.length} mappings</span>
          {ambiguous.map((mapping) => (
            <button key={mapping.id} type="button" onClick={() => onMappingSelected(mapping)}>
              {mapping.kind} · {mapping.id}
            </button>
          ))}
        </div>
      )}
    </section>
  );
}
