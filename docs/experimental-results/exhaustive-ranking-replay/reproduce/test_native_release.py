"""Check the outer release inventory and fail-closed final publication boundary."""
import hashlib
from pathlib import Path
import tempfile
import unittest

from export_repaired import collect
from native_release import inventory, verify_inventory


class ReleaseGuards(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.root = self.base/"publication"
        self.root.mkdir()
        (self.root/"receipt.json").write_text("{}\n")
        (self.root/"ledger").mkdir()
        (self.root/"ledger"/"observations").write_text("measured state\n")
        self.manifest = self.root/"SHA256SUMS"
        self.manifest.write_text("".join(f"{digest}  {name}\n" for name, digest in inventory(self.root).items()))

    def test_exact_inventory(self):
        verify_inventory(self.root)

    def test_changed_known_bytes(self):
        (self.root/"receipt.json").write_text('{"changed":true}\n')
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_unlisted_file(self):
        (self.root/".extra").touch()
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_omitted_entry(self):
        self.manifest.write_text(self.manifest.read_text().splitlines()[0]+"\n")
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_missing_file(self):
        (self.root/"receipt.json").unlink()
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_duplicate_record(self):
        s = self.manifest.read_text()
        self.manifest.write_text(s + s.splitlines()[0] + "\n")
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_path_traversal(self):
        f = self.base/"outside"
        f.write_bytes(b"elsewhere")
        self.manifest.write_text(self.manifest.read_text()+hashlib.sha256(f.read_bytes()).hexdigest()+"  ../outside\n")
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_symlink(self):
        link = self.root/"alias"
        link.symlink_to(self.root/"receipt.json")
        with self.assertRaises(ValueError):
            verify_inventory(self.root)

    def test_absent_final_registration(self):
        before = inventory(self.root)
        with self.assertRaisesRegex(ValueError, "Final launch is pending"):
            collect(self.base, self.root, self.base)
        self.assertEqual(inventory(self.root), before)
        self.assertFalse((self.root/"repaired").exists())


if __name__ == "__main__":
    unittest.main()
