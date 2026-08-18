import { CheckCircle2, FileQuestion } from "lucide-react";
import type { Certificate } from "../../api/types";
import { SlotChip } from "../Common/SlotChip";

export function CertificateView({ certificate }: { certificate: Certificate }) {
  const known = [
    "alpha-equivalence",
    "ACI-normalization",
    "slot-bijection",
    "support-inclusion",
    "rewrite",
    "congruence",
    "source-to-kernel",
    "leader-kernel-trace",
  ].includes(certificate.kind);
  return (
    <div className={`certificate-view ${known ? "" : "unknown-certificate"}`}>
      <div className="certificate-heading">
        {known ? <CheckCircle2 size={15} /> : <FileQuestion size={15} />}
        <div><strong>{certificate.title ?? certificate.kind}</strong><code>{certificate.id}</code></div>
      </div>
      {certificate.summary && <p>{certificate.summary}</p>}
      {certificate.premises && certificate.premises.length > 0 && (
        <div className="certificate-section">
          <span>Premises</span>
          {certificate.premises.map((premise, index) => (
            <div className="certificate-term" key={index}>
              <code>{premise.text ?? "Structured premise"}</code>
              {premise.slotIds?.map((slot) => <SlotChip key={slot} id={slot} />)}
            </div>
          ))}
        </div>
      )}
      {certificate.steps && certificate.steps.length > 0 && (
        <ol className="certificate-steps">
          {certificate.steps.map((step, index) => (
            <li key={`${step.index ?? index}-${step.rule ?? "step"}`}>
              <span>{step.index ?? index + 1}</span>
              <div><strong>{step.rule ?? "evidence"}</strong><small>{step.summary ?? step.term?.text ?? "Structured certificate step"}</small></div>
            </li>
          ))}
        </ol>
      )}
      {certificate.conclusion && (
        <div className="certificate-section conclusion">
          <span>Conclusion</span>
          <code>{certificate.conclusion.text ?? "Structured conclusion"}</code>
          <div>{certificate.conclusion.slotIds?.map((slot) => <SlotChip key={slot} id={slot} />)}</div>
        </div>
      )}
      {!known && certificate.metadata && (
        <dl className="metadata-grid compact">
          {Object.entries(certificate.metadata).map(([key, value]) => (
            <div key={key}><dt>{key}</dt><dd>{String(value)}</dd></div>
          ))}
        </dl>
      )}
    </div>
  );
}

