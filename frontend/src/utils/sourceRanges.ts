import type { SourceMapping, SourcePosition, SourceRange } from "../api/types";

export interface MonacoRangeLike {
  startLineNumber: number;
  startColumn: number;
  endLineNumber: number;
  endColumn: number;
}

export function toMonacoRange(range: SourceRange): MonacoRangeLike {
  return {
    startLineNumber: range.start.line,
    startColumn: range.start.column,
    endLineNumber: range.end.line,
    endColumn: range.end.column,
  };
}

export function containsPosition(range: SourceRange, position: SourcePosition): boolean {
  const afterStart = position.line > range.start.line
    || (position.line === range.start.line && position.column >= range.start.column);
  const beforeEnd = position.line < range.end.line
    || (position.line === range.end.line && position.column <= range.end.column);
  return afterStart && beforeEnd;
}

export function mappingsAtPosition(
  mappings: SourceMapping[],
  position: SourcePosition,
): SourceMapping[] {
  return mappings.filter((mapping) => containsPosition(mapping.sourceRange, position));
}

export function mappingsForEntity(
  mappings: SourceMapping[],
  eclassId?: string,
  enodeId?: string,
): SourceMapping[] {
  return mappings.filter((mapping) =>
    (eclassId !== undefined && mapping.eclassIds?.includes(eclassId))
    || (enodeId !== undefined && mapping.enodeIds?.includes(enodeId)));
}

export function mappingsForEntities(
  mappings: SourceMapping[],
  entityIds: Iterable<string>,
): SourceMapping[] {
  const selected = new Set(entityIds);
  if (selected.size === 0) return [];
  return mappings.filter((mapping) =>
    mapping.eclassIds?.some((id) => selected.has(id))
    || mapping.enodeIds?.some((id) => selected.has(id)));
}
