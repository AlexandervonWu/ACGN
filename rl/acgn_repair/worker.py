"""A timeout always kills and reaps the Java process group."""

import json
import os
from pathlib import Path
import selectors
import signal
import subprocess
import time


class WorkerError(RuntimeError):
    pass


class JavaWorker:
    def __init__(self, root, classes, log, timeout=30, heap="2g", command=None):
        if timeout <= 0:
            raise ValueError("Timeout must be positive")
        self.timeout = timeout
        self.serial = 0
        self.buffer = b""
        self.log = Path(log).open("wb")
        argv = command or ["java", "-ea", "-Xmx" + heap, "-Djava.awt.headless=true", "-Dfile.encoding=UTF-8", "-cp",
                           str(classes) + os.pathsep + str(Path(root) / "lib/*"),
                           "is.fivefivefive.ACGN.repair.RepairWorkerMain"]
        try:
            self.process = subprocess.Popen(argv, cwd=root, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                            stderr=self.log, start_new_session=True)
        except Exception:
            self.log.close()
            raise
        self.selector = selectors.DefaultSelector()
        self.selector.register(self.process.stdout, selectors.EVENT_READ)

    def request(self, op, **fields):
        self.serial += 1
        request = dict(fields, op=op, id=self.serial)
        deadline = time.monotonic() + self.timeout
        try:
            self.process.stdin.write((json.dumps(request) + "\n").encode())
            self.process.stdin.flush()
            while b"\n" not in self.buffer:
                remaining = deadline - time.monotonic()
                if remaining <= 0 or not self.selector.select(remaining):
                    raise WorkerError("TIMEOUT: Java worker exceeded response deadline")
                block = os.read(self.process.stdout.fileno(), 65536)
                if not block:
                    raise WorkerError("Java worker exited before replying")
                self.buffer += block
                if len(self.buffer) > 8 * 1024 * 1024:
                    raise WorkerError("Java reply exceeds byte bound")
            line, self.buffer = self.buffer.split(b"\n", 1)
            reply = json.loads(line)
            if reply.get("id") != self.serial or reply.get("protocol") != "repair-worker-v1":
                raise WorkerError("Protocol/version mismatch")
            if not reply.get("ok"):
                raise WorkerError(reply.get("error", "ABORTED"))
            return reply
        except Exception:
            self.close()
            raise

    def close(self):
        if self.process.poll() is None:
            try:
                os.killpg(self.process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        self.process.wait()
        self.selector.close()
        self.process.stdin.close()
        self.process.stdout.close()
        self.log.close()

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()
