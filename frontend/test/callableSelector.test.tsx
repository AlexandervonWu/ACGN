import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { PredicatePipelinePanel } from "../src/components/PredicateSelector/PredicatePipelinePanel";

describe("callable selector", () => {
  it("lists and selects Alloy functions alongside predicates", async () => {
    const user = userEvent.setup();
    const select = vi.fn();
    const selectComparison = vi.fn();
    const compare = vi.fn();
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
      comparisonTarget="neighbors"
      exampleName="simple"
      inspecting={false}
      comparing={false}
      canCompare
      onSelectPredicate={select}
      onSelectComparisonTarget={selectComparison}
      onCompare={compare}
      onSelectStage={vi.fn()}
      onSelectExample={vi.fn()}
    />);

    const target = screen.getByRole("combobox", { name: "Callable to visualize" });
    expect(within(target).getByRole("option", { name: /connected - pred/i })).toBeInTheDocument();
    expect(within(target).getByRole("option", { name: /neighbors - set User/i })).toBeInTheDocument();
    await user.selectOptions(target, "neighbors");
    expect(select).toHaveBeenCalledWith("neighbors");

    const comparisonTarget = screen.getByRole("combobox", { name: "Callable to compare with" });
    await user.selectOptions(comparisonTarget, "connected");
    expect(selectComparison).toHaveBeenCalledWith("connected");
    await user.click(screen.getByRole("button", { name: "Compare callables" }));
    expect(compare).toHaveBeenCalledOnce();
  });
});
