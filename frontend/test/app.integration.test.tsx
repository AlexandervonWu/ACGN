import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { cleanup, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { App } from "../src/app/App";
import { defaultGraphFilters, useUiStore } from "../src/state/uiStore";

describe("mock-backed explorer workflow", () => {
  afterEach(() => cleanup());

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

    await screen.findAllByRole("option", { name: /inv7 - pred/i }, { timeout: 2500 });
    const target = screen.getByRole("combobox", { name: "Callable to visualize" });
    await user.selectOptions(target, "inv7");
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

  it("discovers and renders a relation-valued Alloy function", async () => {
    window.history.replaceState({}, "", "/?example=callables");
    const user = userEvent.setup();
    const client = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
    render(<QueryClientProvider client={client}><App /></QueryClientProvider>);

    await screen.findAllByRole("option", { name: /neighbors - set User/i }, { timeout: 2500 });
    const target = screen.getByRole("combobox", { name: "Callable to visualize" });
    await user.selectOptions(target, "neighbors");
    await user.click(screen.getByRole("button", { name: /^analyze$/i }));

    await waitFor(() => expect(screen.getByTestId("react-flow")).toBeInTheDocument(), { timeout: 2500 });
    expect(screen.getAllByText("E2").length).toBeGreaterThan(0);
  });

  it("compares two selected callable positions and visualizes a certified edit path", async () => {
    const user = userEvent.setup();
    const client = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
    render(<QueryClientProvider client={client}><App /></QueryClientProvider>);

    await screen.findAllByRole("option", { name: /inv7 - pred/i }, { timeout: 2500 });
    await user.selectOptions(
      screen.getByRole("combobox", { name: "Callable to visualize" }),
      "inv7",
    );
    await user.selectOptions(
      screen.getByRole("combobox", { name: "Callable to compare with" }),
      "inv7",
    );
    await user.click(screen.getByRole("button", { name: "Compare callables" }));

    expect(await screen.findByRole("region", { name: "Edit distance comparison" }, { timeout: 2500 })).toBeInTheDocument();
    expect(screen.getByText("Certified equivalent")).toBeInTheDocument();
    expect(screen.getByText("Certified semantic equality; no repair is required.")).toBeInTheDocument();
  });
});
