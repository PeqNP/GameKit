
class GradleConfigBuilder (object):
    def __init__(self):
        self.registry = []

    def add(self, *path):
        new_entry = list(path)
        for entry in self.registry:
            if new_entry == entry: break
        self.registry.append(new_entry)

    def insert(self, at_idx, *path):
        new_entry = list(path)
        if not self.registry:
            self.registry.append(new_entry)
            return
        prev_entry = None
        current_idx = 0
        for idx, entry in self.registry:
            if prev_entry is None:
                prev_entry = entry
            elif prev_entry[0] != entry[0]:
                # At the very end of this group. Now add the entry.
                if current_idx == at_idx: break
                current_idx += 1
            # Insert the new entry if the entry occupying the index
            # is not of the same group. Otherwise, wait until the
            # last entry in the group has been added.
            if current_idx == at_idx and new_entry[0] != entry[0]:
                break
            prev_entry = entry
        self.registry.insert(current_idx, new_entry)

