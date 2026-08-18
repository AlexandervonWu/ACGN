import { fireEvent, render, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { SourceEditor } from "../src/components/SourceEditor/SourceEditor";

describe("Alloy file import", () => {
  it("loads an .als file into the source model for callable inspection", async () => {
    const source = [
      "module modules/TicTacToe",
      "open util/ordering[GameState]",
      "sig GameState { turn: one Symbol }",
      "sig Symbol {}",
      "fun NextTurn[s: GameState]: one Symbol { s.turn }",
      "pred Win[s: GameState] { some s.turn }",
    ].join("\n");
    const onChange = vi.fn();
    const { container } = render(<SourceEditor
      model="sig Placeholder {}"
      diagnostics={[]}
      mappings={[]}
      slotEntityIds={[]}
      ambiguousMappingIds={[]}
      inspecting={false}
      onChange={onChange}
      onAnalyze={vi.fn()}
      onMappingsSelected={vi.fn()}
      onMappingSelected={vi.fn()}
    />);
    const input = container.querySelector<HTMLInputElement>('input[type="file"]');
    expect(input).not.toBeNull();
    const file = new File([source], "tictactoe.als", { type: "text/plain" });
    Object.defineProperty(file, "text", { value: async () => source });

    fireEvent.change(input!, { target: { files: [file] } });

    await waitFor(() => expect(onChange).toHaveBeenCalledWith(source));
  });
});
