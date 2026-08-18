import { useUiStore } from "../../state/uiStore";

interface SlotChipProps {
  id: string;
  type?: string;
  label?: string;
}

export function SlotChip({ id, type, label }: SlotChipProps) {
  const selectedSlotId = useUiStore((state) => state.selectedSlotId);
  const hoveredSlotId = useUiStore((state) => state.hoveredSlotId);
  const setSelectedSlot = useUiStore((state) => state.setSelectedSlot);
  const setHoveredSlot = useUiStore((state) => state.setHoveredSlot);
  const active = selectedSlotId === id || hoveredSlotId === id;
  return (
    <button
      type="button"
      className={`slot-chip ${active ? "is-active" : ""}`}
      title={type ? `${id}: ${type}` : id}
      onClick={(event) => {
        event.stopPropagation();
        setSelectedSlot(selectedSlotId === id ? undefined : id);
      }}
      onMouseEnter={() => setHoveredSlot(id)}
      onMouseLeave={() => setHoveredSlot(undefined)}
    >
      {label ?? id}
    </button>
  );
}

