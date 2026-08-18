import { describe, expect, it } from "vitest";
import { containsPosition, mappingsAtPosition, toMonacoRange } from "../src/utils/sourceRanges";

const range = {
  start: { line: 4, column: 3 },
  end: { line: 6, column: 12 },
};

describe("source ranges", () => {
  it("preserves the API's 1-based coordinates for Monaco", () => {
    expect(toMonacoRange(range)).toEqual({
      startLineNumber: 4,
      startColumn: 3,
      endLineNumber: 6,
      endColumn: 12,
    });
  });

  it("supports one source location mapping to multiple graph objects", () => {
    const mappings = [
      { id: "M0", sourceRange: range, kind: "origin" as const, eclassIds: ["E0"] },
      { id: "M1", sourceRange: range, kind: "derived" as const, enodeIds: ["N1"] },
    ];
    expect(containsPosition(range, { line: 5, column: 2 })).toBe(true);
    expect(mappingsAtPosition(mappings, { line: 5, column: 2 })).toHaveLength(2);
  });
});

