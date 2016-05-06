
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
    def __init__(self, tab_space=4, source=None):
        self.tab_space = tab_space
        self.registry = []
        if source:
            self.loadSource(source)

    def loadSource(self, source):
        # Create tuples that will then be added.
        pass

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
