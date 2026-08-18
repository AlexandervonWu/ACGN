package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** In-memory proof-retaining trace used only by explicit verification sessions. */
public final class RecordingCertificateTraceSink implements CertificateTraceSink {
    private final List<CertificateTraceEvent> events = new ArrayList<>();

    @Override
    public boolean enabled() {
        return true;
    }

    @Override
    public synchronized void append(CertificateTraceEvent event) {
        if (event.sequence() != events.size()) {
            throw new IllegalStateException("Certificate trace sequence is not consecutive");
        }
        if (!events.isEmpty()) {
            CertificateTraceEvent prior = events.get(events.size() - 1);
            if (!prior.after().stateKey().equals(event.before().stateKey())) {
                throw new IllegalStateException(
                        "Certificate trace has a state discontinuity");
            }
        }
        events.add(event);
    }

    public synchronized List<CertificateTraceEvent> events() {
        return Collections.unmodifiableList(new ArrayList<>(events));
    }
}
