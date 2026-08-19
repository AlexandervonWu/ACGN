import React, { useEffect, useState } from "react";
import "@testing-library/jest-dom/vitest";
import { vi } from "vitest";

vi.stubEnv("VITE_USE_MOCK_API", "true");

class ResizeObserverStub {
  observe() {}
  unobserve() {}
  disconnect() {}
}

vi.stubGlobal("ResizeObserver", ResizeObserverStub);
Object.defineProperty(URL, "createObjectURL", { value: vi.fn(() => "blob:test") });
Object.defineProperty(URL, "revokeObjectURL", { value: vi.fn() });
Object.defineProperty(navigator, "clipboard", {
  value: { writeText: vi.fn(async () => undefined) },
  configurable: true,
});

vi.mock("@monaco-editor/react", () => ({
  default: ({ value, onChange, onMount, beforeMount }: {
    value: string;
    onChange?: (value: string) => void;
    onMount?: (editor: unknown, monaco: unknown) => void;
    beforeMount?: (monaco: unknown) => void;
  }) => {
    const [mouseHandler, setMouseHandler] = useState<((event: unknown) => void)>();
    useEffect(() => {
      const monaco = {
        KeyMod: { CtrlCmd: 1 },
        KeyCode: { Enter: 3 },
        MarkerSeverity: { Error: 8, Warning: 4, Info: 2 },
        languages: {
          getLanguages: () => [],
          register: vi.fn(),
          setMonarchTokensProvider: vi.fn(),
        },
        editor: { defineTheme: vi.fn(), setModelMarkers: vi.fn() },
      };
      const editor = {
        addCommand: vi.fn(),
        onMouseDown: (handler: (event: unknown) => void) => setMouseHandler(() => handler),
        createDecorationsCollection: () => ({ clear: vi.fn() }),
        revealRangeInCenterIfOutsideViewport: vi.fn(),
        getModel: () => ({}),
      };
      beforeMount?.(monaco);
      onMount?.(editor, monaco);
    }, []);
    return (
      <div data-testid="mock-monaco">
        <textarea aria-label="Alloy source editor" value={value} onChange={(event) => onChange?.(event.target.value)} />
        <button
          type="button"
          aria-label="Select source mapping"
          onClick={() => mouseHandler?.({ target: { position: { lineNumber: 9, column: 10 } } })}
        >source mapping</button>
      </div>
    );
  },
  loader: { config: vi.fn() },
}));

vi.mock("@xyflow/react", () => ({
  ReactFlowProvider: ({ children }: { children: React.ReactNode }) => <>{children}</>,
  ReactFlow: ({ nodes, edges, nodeTypes, children, onPaneClick }: {
    nodes: Array<{ id: string; type: string; data: Record<string, unknown> }>;
    edges: Array<{ id: string; label?: React.ReactNode; className?: string }>;
    nodeTypes: Record<string, React.ComponentType<{ id: string; data: Record<string, unknown> }>>;
    children?: React.ReactNode;
    onPaneClick?: () => void;
  }) => (
    <div data-testid="react-flow">
      <button type="button" aria-label="Graph canvas" onClick={onPaneClick}>canvas</button>
      {nodes.map((node) => {
        const Component = nodeTypes[node.type];
        return Component ? <Component key={node.id} id={node.id} data={node.data} /> : null;
      })}
      {edges.map((edge) => (
        <div
          key={edge.id}
          data-testid="flow-edge"
          data-edge-id={edge.id}
          className={edge.className}
        >
          {edge.label}
        </div>
      ))}
      {children}
    </div>
  ),
  Background: () => null,
  Controls: () => null,
  MiniMap: () => null,
  Handle: () => null,
  Position: { Top: "top", Bottom: "bottom" },
  MarkerType: { ArrowClosed: "arrowclosed" },
  BackgroundVariant: { Dots: "dots" },
  useNodesState: <T,>(initial: T[]) => {
    const [nodes, setNodes] = useState(initial);
    return [nodes, setNodes, vi.fn()] as const;
  },
  useReactFlow: () => ({
    fitView: vi.fn(async () => undefined),
    getNode: vi.fn(() => undefined),
    setCenter: vi.fn(async () => undefined),
  }),
}));
