
class Node (object):
    def __init__(self, leaf, num_spaces=4):
        self.name = leaf[0]
        self.num_spaces = num_spaces
        leaves = leaf[1:]
        if len(leaves):
            self.leaves = [Node(leaves, num_spaces)]
        else:
            self.leaves = None

    # Returns true when the leaves are added to this branch. False, otherwise.
    def add(self, leaves):
        if leaves[0] != self.name: return False
        leaves = leaves[1:]
        if not len(leaves): return False
        for leaf in self.leaves:
            if leaf.add(leaves): return True
        self.leaves.append(Node(leaves, self.num_spaces))
        return True

    def generate(self, level):
        spaces = (level * self.num_spaces) * " "
        if not self.leaves:
            return spaces + self.name
        blocks = [leaf.generate(level+1) for leaf in self.leaves]
        return "{}{} {{\n{}\n{}}}".format(spaces, self.name, "\n".join(blocks), spaces)

class GradleConfigBuilder (object):
    def __init__(self, tab_space=4, source=None, filepath=None):
        self.tab_space = tab_space
        self.registry = []
        if source:
            self.load_source(source)
        elif filepath:
            self.load_file(filepath)

    #
    # Load a config from source.
    #
    # When loading from source, it expects every command to be on its own line.
    # Having commands like 'dependencies {\n command; }' are not allowed. But
    # 'dependencies {\n command \n}' are allowed.
    #
    def load_source(self, source):
        paths = self.get_paths(source)
        for path in paths:
            self.add(*path)

    def load_file(self, filepath):
        fh = open(filepath, "r")
        source = fh.read()
        fh.close()
        self.load_source(source)

    def get_paths(self, source):
        # Create tuples that will then be added.
        nodes = []
        paths = []
        for line in source.split("\n"):
            if "{" in line and "}" in line:
                nodes.append(line.strip())
                paths.append(nodes[:])
                nodes.pop()
            elif "{" in line:
                pos = line.find("}")
                nodes.append(line[:pos].strip())
            elif "}" in line:
                nodes.pop()
            elif len(line.strip()) and line.strip()[0:2] != "//":
                nodes.append(line.strip())
                paths.append(nodes[:])
                nodes.pop()
        return paths

    def add(self, *path):
        new_entry = list(path)
        for entry in self.registry:
            if new_entry == entry: return
        self.registry.append(new_entry)

    def insert(self, at_idx, *path):
        new_entry = list(path)
        if not self.registry:
            self.registry.append(new_entry)
            return
        prev_entry = None
        current_idx = 0
        idx = 0
        for entry in self.registry:
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
            idx += 1
        self.registry.insert(idx, new_entry)

    def after(self, after_entry, *path):
        new_entry = list(path)
        for idx, entry in enumerate(self.registry):
            if entry == after_entry:
                next_idx = idx + 1
                # Already exists.
                if next_idx < len(self.registry) and self.registry[next_idx] == new_entry:
                    return
                self.registry.insert(next_idx, new_entry)
                return

    def replace(self, subject, replacement):
        registry = []
        for entry in self.registry[:]:
            for idx, item in enumerate(entry[:]):
                if subject in item:
                    item = item.replace(subject, str(replacement))
                    entry[idx] = item
            registry.append(entry)
        self.registry = registry

    def get_nodes(self):
        def add_node(nodes, entry):
            for node in nodes:
                if node.add(entry):
                    return True
            return False
        nodes = []
        for entry in self.registry:
            if not add_node(nodes, entry):
                nodes.append(Node(entry))
        return nodes

    def generate(self):
        blocks = []
        for node in self.get_nodes():
            blocks.append(node.generate(0))
        return "\n\n".join(blocks)

    def save(self, filepath):
        fh = open(filepath, "w")
        fh.write(self.generate())
        fh.close()
