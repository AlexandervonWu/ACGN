import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it } from "vitest";
import { CertificateView } from "../src/components/Certificates/CertificateView";
import { defaultGraphFilters, useUiStore } from "../src/state/uiStore";

describe("slot state and generic certificates", () => {
  beforeEach(() => {
    useUiStore.setState({
      selectedSlotId: undefined,
      hoveredSlotId: undefined,
      graphFilters: defaultGraphFilters,
    });
  });

  it("retains slot highlighting until it is cleared", () => {
    useUiStore.getState().setSelectedSlot("#2");
    expect(useUiStore.getState().selectedSlotId).toBe("#2");
    useUiStore.getState().clearSelections();
    expect(useUiStore.getState().selectedSlotId).toBe("#2");
    useUiStore.getState().setSelectedSlot(undefined);
    expect(useUiStore.getState().selectedSlotId).toBeUndefined();
  });

  it("renders an unknown certificate kind as generic structured evidence", async () => {
    const user = userEvent.setup();
    render(<CertificateView certificate={{
      id: "C-future",
      kind: "future-proof-kind",
      summary: "Opaque backend evidence",
      metadata: { producer: "test", rank: 4 },
    }} />);
    expect(screen.getByText("future-proof-kind")).toBeInTheDocument();
    expect(screen.getByText("producer")).toBeInTheDocument();
    expect(screen.getByText("test")).toBeInTheDocument();
    await user.click(screen.getByText("future-proof-kind"));
  });
});
