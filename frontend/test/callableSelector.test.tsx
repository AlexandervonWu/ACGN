import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { PredicatePipelinePanel } from "../src/components/PredicateSelector/PredicatePipelinePanel";

describe("callable selector", () => {
  it("lists and selects Alloy functions alongside predicates", async () => {
    const user = userEvent.setup();
    const select = vi.fn();
    render(<PredicatePipelinePanel
      inspection={{
        callables: [
          { name: "connected", kind: "predicate" },
          { name: "neighbors", kind: "function", returnType: "set User" },
        ],
        predicates: [{ name: "connected" }],
        parseDiagnostics: [],
      }}
      selectedPredicate="connected"
      exampleName="simple"
      inspecting={false}
      onSelectPredicate={select}
      onSelectStage={vi.fn()}
      onSelectExample={vi.fn()}
    />);

    expect(screen.getByRole("option", { name: /connected pred/i })).toBeInTheDocument();
    await user.click(screen.getByRole("option", { name: /neighbors set User/i }));
    expect(select).toHaveBeenCalledWith("neighbors");
  });
});
