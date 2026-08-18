import type { AnalysisStatistics } from "../../api/types";
import { formatMilliseconds } from "../../utils/formatters";

export function StatisticsStrip({ statistics }: { statistics?: AnalysisStatistics }) {
  if (!statistics) return null;
  const values = [
    statistics.eclassCount !== undefined && `${statistics.eclassCount.toLocaleString()} e-classes`,
    statistics.enodeCount !== undefined && `${statistics.enodeCount.toLocaleString()} e-nodes`,
    statistics.mergeCount !== undefined && `${statistics.mergeCount.toLocaleString()} merges`,
    statistics.saturationRounds !== undefined && `${statistics.saturationRounds.toLocaleString()} rounds`,
    statistics.totalMs !== undefined && formatMilliseconds(statistics.totalMs),
  ].filter((value): value is string => Boolean(value));
  return <div className="statistics-strip">{values.map((value) => <span key={value}>{value}</span>)}</div>;
}

