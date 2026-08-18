import type { ReactNode } from "react";

interface PanelHeaderProps {
  title: string;
  count?: number;
  actions?: ReactNode;
}

export function PanelHeader({ title, count, actions }: PanelHeaderProps) {
  return (
    <div className="panel-header">
      <div className="panel-title">
        <span>{title}</span>
        {count !== undefined && <span className="panel-count">{count.toLocaleString()}</span>}
      </div>
      {actions && <div className="panel-actions">{actions}</div>}
    </div>
  );
}

