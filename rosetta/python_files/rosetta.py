import sys

lines = sys.__stdin__.readlines()
lines = [ x.strip() for x in lines ]

it = iter(lines)
edges = zip(it, it)


vertices = set()
for (a,b) in edges:
    vertices.add(a)
    vertices.add(b)

graph = {}

for v in vertices:
    graph.setdefault(v, [])

for (a,b) in edges:
    graph[a].append(b)

def print_graph(graph):
    print("Current Graph")
    for k in graph:
        print("%s" % (k)),
        print(graph[k])

def get_nodes_to_remove(graph):
    nodes_to_remove = []
    for key in graph:
        if (len(graph[key]) == 0):
            nodes_to_remove.append(key)
    return sorted(nodes_to_remove)

L = [] # List containing sorted elements
S = get_nodes_to_remove(graph) # Set of all nodes with no incoming edges

# Kahn's Algorithm
while len(S) > 0:
    n = S.pop(0)
    L.append(n)

    for key_node in graph:
        if n in graph[key_node]:
            graph[key_node].remove(n)
            if len(graph[key_node]) == 0:
                S.append(key_node)
                S = sorted(S)

for key in graph:
    if len(graph[key]) > 0:
        print("cycle")
        sys.exit()
for elt in L:
    print(elt)


        




       













