import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { App } from "../src/app/App";
import { defaultGraphFilters, useUiStore } from "../src/state/uiStore";

describe("mock-backed explorer workflow", () => {
  beforeEach(() => {
    window.history.replaceState({}, "", "/?example=slots");
    useUiStore.setState({
      selectedPredicate: undefined,
      selectedEClassId: undefined,
      selectedENodeId: undefined,
      equivalenceENodeIds: [],
      selectedSlotId: undefined,
      expandedClasses: new Set(),
      graphFilters: defaultGraphFilters,
      currentStageId: undefined,
      ambiguousMappingIds: [],
      highlightedEntityIds: [],
    });
  });

  it("loads, analyzes, selects an e-class, inspects it, and follows a source mapping", async () => {
    const user = userEvent.setup();
    const client = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
    render(<QueryClientProvider client={client}><App /></QueryClientProvider>);

    const predicate = await screen.findByRole("option", { name: /inv7/i }, { timeout: 2500 });
    await user.click(predicate);
    await user.click(screen.getByRole("button", { name: /^analyze$/i }));

    await waitFor(() => expect(screen.getByTestId("react-flow")).toBeInTheDocument(), { timeout: 2500 });
    expect(screen.getAllByText("E0").length).toBeGreaterThan(0);
    await user.click(screen.getAllByText("E0")[0]!);
    expect(screen.getByText("Canonical node")).toBeInTheDocument();

    await user.click(await screen.findByRole("button", { name: "Select source mapping" }));
    expect(await screen.findByText(/mappings$/i)).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: /binder · M-u1/i }));
    expect(screen.getByText("N1")).toBeInTheDocument();
    expect(screen.getByText("QuantifierBlock")).toBeInTheDocument();
  });
});
