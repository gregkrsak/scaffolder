extends Node2D
class_name InterSurfaceEdgesAnnotator

var graph: PlatformGraph

func _init(graph: PlatformGraph) -> void:
    self.graph = graph

func _draw() -> void:
    var hue: float
    var discrete_trajectory_color: Color
    var continuous_trajectory_color: Color
    var waypoint_color: Color
    var instruction_start_stop_color: Color
    var edge: Edge
    var position_start: Vector2
    var position_end: Vector2
    
    # Iterate over all surfaces.
    for surface in graph.surfaces_to_outbound_nodes:
        # Iterate over all nodes from this surface.
        for origin_node in graph.surfaces_to_outbound_nodes[surface]:
            # Iterate over all edges from this node.
            for destination_node in graph.nodes_to_nodes_to_edges[origin_node]:
                edge = graph.nodes_to_nodes_to_edges[origin_node][destination_node]
                
                # Skip intra-surface edges. They aren't as interesting to render.
                if edge is IntraSurfaceEdge:
                    continue
                
                DrawUtils.draw_edge( \
                        self, \
                        edge, \
                        true, \
                        true, \
                        true)
