local Bool = require 'toolbox.core.bool'
local Err = require 'toolbox.error.error'
local Node = require 'toolbox.extensions.node'
local Table = require 'toolbox.core.table'

local EdgeDirection = Node.EdgeDirection

local ternary = Bool.ternary

--- A representation of a graph.
---
---@class Graph<T>
---@field private nodes { [`T`]: Node }
---@field private directed boolean
local Graph = {}
Graph.__index = Graph

--- Constructor
---
---@param nodes Node[]|nil: the nodes that comprise the graph
---@param directed boolean: optional, defaults to false; if true, indicates that this
--- graph is a directed graph (i.e.: edges have directionality)
---@return Graph: a new instance
function Graph.new(nodes, directed)
  return setmetatable({
    nodes = Table.to_dict(nodes or {}, function(e, _)
      return e.label, e
    end),
    directed = Bool.or_default(directed, false),
  }, Graph)
end

--- Constructs a new undirected graph.
---
---@param nodes Node[]|nil: the nodes that comprise the graph
---@return Graph: a new undirected graph instance
function UndirectedGraph(nodes)
  return Graph.new(nodes, false)
end

--- Constructs a new directed graph.
---
---@param nodes Node[]|nil: the nodes that comprise the graph
---@return Graph: a new directed graph instance
function DirectedGraph(nodes)
  return Graph.new(nodes, true)
end

---@return string|nil
local function get_label(node)
  return ternary(Node.is(node), function()
    return node.label
  end, node)
end

local function as_node(node)
  return ternary(Node.is(node), node, Node.as(node))
end

--- Checks if the graph contains "node".
---
---@note: the containment check uses only a node's label
---
---@generic T
---@param node Node|T: the node to check; can be a node or a node label
---@return boolean: true if this graph contains node, false otherwise
function Graph:has_node(node)
  local label = get_label(node)
  return self.nodes[label] ~= nil
end

--- Gets the node in the graph w/ a matching label, if it exists.
---
---@generic T
---@param node Node|T: the node to retrieve from the graph; can be a node or a node label
---@return Node|nil: the node in graph w/ a matching label, if it exists
function Graph:get_node(node)
  local label = get_label(node)
  return self.nodes[label]
end

---@private
---@return EdgeDirction
function Graph:get_direction()
  return ternary(self.directed, EdgeDirection.OUTBOUND, EdgeDirection.UNDIRECTED)
end

--- Adds a node to the graph.
---
---@generic T
---@param node Node|T: the node to add to the graph; can be a node or a node label
---@param strict boolean: if true, this method raises an error if a node w/ the same label
--- already exists in the graph; if false, the new node will overwrite any existing node
--- w/ the same label
---@error if strict == true and there's already a node in the graph w/ the same label
function Graph:add_node(node, strict)
  node = as_node(node)
  strict = Bool.or_default(strict, false)

  if strict and self:has_node(node) then
    Err.raise('Graph.add_node: node="%s" already exists', node.label)
  end

  self.nodes[node.label] = node
end

function Graph:has_edge(src, dst, strict)
  src = self:get_node(src)
  dst = self:get_node(dst)

  strict = Bool.or_default(strict, false)

  if strict and src == nil then
    Err.raise('Graph.has_edge: src="%s" does not exist', get_label(src))
  end

  if strict and dst == nil then
    Err.raise('Graph.has_edge: dst="%s" does not exist', get_label(dst))
  end

  if src == nil or dst == nil then
    return false
  end

  local direction = self:get_direction()
  return src:has_edge(dst, direction)
end

--- Adds an edge to the graph. If strict is false, nodes will be added to the graph if
--- either of the provided nodes doesn't exist.
---
---@generic T
---@param src Node|T: the "source" node, i.e.: in a digraph, the node from which an edge
--- originates
---@param dst Node|T: the "destination" node, i.e.: in a digraph, the node at which an
--- edge terminates
---@param strict boolean: if true, the method raises an error if either src or dst doesn't
--- exist in the graph
function Graph:add_edge(src, dst, strict)
  if strict and not self:has_node(src) then
    Err.raise('Graph.add_edge: no such node="%s"', src.label)
  elseif not self:has_node(src) then
    self:add_node(src, strict)
  end

  if strict and not self:has_node(dst) then
    Err.raise('Graph.add_edge: no such node="%s"', dst.label)
  elseif not self:has_node(dst) then
    self:add_node(dst, strict)
  end

  src = self:get_node(src)
  dst = self:get_node(dst)

  if src == nil or dst == nil then
    error 'Graph.add_edge: expected src/dst to exist in graph'
  end

  local direction = self:get_direction()
  return src:add_edge(dst, direction)
end

return Graph
