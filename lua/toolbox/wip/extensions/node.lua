local Bool = require 'toolbox.core.bool'
local Err = require 'toolbox.error.error'
local Type = require 'toolbox.meta.type'

--- Enumerates possible directions of an edge.
---
---@enum EdgeDirction
local EdgeDirction = {
  INBOUND = 'inbound', -- indicates that an edge goes from a node
  OUTBOUND = 'outbound', -- indicates that an edge goes to a node
  UNDIRECTED = 'undirected', -- indicates that an edge is undirected (bi-directional)
}

local DEFAULT_EDGE_DIRECTION = EdgeDirction.OUTBOUND

---@return EdgeDirction: the default edge direction
function EdgeDirction.default()
  return DEFAULT_EDGE_DIRECTION
end

--- Gets the edge nodes from the provided node based on the provided direction.
---
---@generic T
---@param node Node: the node from which to retrieve edge nodes
---@param direction EdgeDirction: the direction for which to retrieve edge nodes
---@return { [T]: Node }: the edge nodes from the provided node relevant to the provided
--- direction
function EdgeDirction.get_edge_nodes(node, direction)
  if direction == EdgeDirction.INBOUND then
    return node.inbound
  end

  return node.outbound
end

--- Gets the opposite of the provided direction.
---
---@param direction EdgeDirction: the direction for which to retrieve the opposite
--- direction
---@return EdgeDirction: the opposite of the provided direction
---@error if the provided direction is invalid
function EdgeDirction.opposite(direction)
  if direction == EdgeDirction.INBOUND then
    return EdgeDirction.OUTBOUND
  elseif direction == EdgeDirction.OUTBOUND then
    return EdgeDirction.INBOUND
  elseif direction == EdgeDirction.UNDIRECTED then
    return EdgeDirction.UNDIRECTED
  end

  ---@note: this raises an error, so ignore the "missing return" warning
  ---@diagnostic disable-next-line: missing-return
  Err.raise('EdgeDirction.opposite: unrecognized edge direction="%s"', direction)
end

--- A representation of a graph node.
---
---@class Node<T>
---@field label `T`: the node's label/data; uniquely identifies a node
---@field package inbound { [`T`]: Node }
---@field package outbound { [`T`]: Node }
local Node = {}
Node.__index = Node

---@note: exposes EdgeDirction enum
Node.EdgeDirection = EdgeDirction

local function add_edge(src, dst, direction, strict)
  local opp_direction = EdgeDirction.opposite(direction)

  local src_edges = EdgeDirction.get_edge_nodes(src, direction)
  local dst_edges = EdgeDirction.get_edge_nodes(dst, opp_direction)

  ---@note: this is to ensure that node edges stay in a consistent state, since each node
  ---       tracks both incoming and outgoing edges
  if
    (src_edges[dst.label] == nil and dst_edges[src.label] ~= nil)
    or (src_edges[dst.label] ~= nil and dst_edges[src.label] == nil)
  then
    Err.raise 'Node.add_edge: src and dst edges are in an inconsistent state'
  end

  if strict and (src_edges[dst.label] ~= nil or dst_edges[src.label] ~= nil) then
    Err.raise('Node.add_edge: the edge "%s -> %s" already exists', src.label, dst.label)
  end

  src_edges[dst.label] = dst
  src_edges[src.label] = src
end

local function validate_directed_nodes(directed_nodes)
  if directed_nodes[EdgeDirction.UNDIRECTED] == nil then
    return
  end

  if directed_nodes[EdgeDirction.OUTBOUND] == nil and directed_nodes[EdgeDirction.INBOUND] == nil then
    return
  end

  Err.raise 'Node.new: a node cannot have both directed and undirected nodes'
end

local function add_edges(src, directed_nodes, strict)
  validate_directed_nodes(directed_nodes)

  strict = Bool.or_default(strict, false)

  for direction, nodes in pairs(directed_nodes) do
    for _, dst in ipairs(nodes) do
      add_edge(src, dst, direction, strict)
    end
  end
end

--- Constructor
---
---@param label any: the node's label/data; uniquely identifies a node
---@param directed_nodes { [EdgeDirction]: Node[] }|nil: a dict-like table of edge
--- directions -> nodes
---@return Node: a new instance
---@private
function Node.new(label, directed_nodes)
  local this = {
    label = label,
    inbound = {},
    outbound = {},
  }

  add_edges(directed_nodes or {}, this, true)
  return setmetatable(this, Node)
end

--- Constructs a directed node.
---
---@param label any: the node's label/data; uniquely identifies a node
---@param directed_nodes { inbound: Node[]|nil, outbound: Node[]|nil }: nodes to which the
--- constructed node will have inbound/outbound edges
---@return Node: a new instance
function Node.directed(label, directed_nodes)
  return Node.new(label, {
    [EdgeDirction.INBOUND] = directed_nodes.inbound or {},
    [EdgeDirction.OUTBOUND] = directed_nodes.outbound or {},
  })
end

--- Checks if the provided object is a Node.
---
---@param o any|nil: the object to check
---@return boolean: true if the provided object is a Node, false otherwise
function Node.is(o)
  return Type.is(o, Node)
end

--- Constructs a node w/ no edges.
---
---@param label any: the node's label/data; uniquely identifies a node
function Node.as(label)
  return Node.new(label)
end

--- Constructs an undirected node.
---
---@param label any: the node's label/data; uniquely identifies a node
---@param nodes Node[]: nodes to which the constructed node will share undirected edges
---@return Node: a new instance
function Node.undirected(label, nodes)
  return Node.new(label, { [EdgeDirction.UNDIRECTED] = nodes })
end

--- Checks if this node has an edge w/ the provided node in the provided direction.
---
---@param node Node: the other node to check for an edge
---@param direction EdgeDirction: optional, defaults to "outbound"; the direction the
--- edge should have
---@return boolean: true if this node has an edge to the provided node, false otherwise
function Node:has_edge(node, direction)
  direction = direction or EdgeDirction.default()

  local edges = EdgeDirction.get_edge_nodes(self, direction)
  return edges[node.label] ~= nil
end

--- Adds an edge b/w this node and the provided node.
---
---@param node Node: the node w/ which to add an undirected edge
---@param direction EdgeDirction: optional, defaults to "outbound"; the direction of the
--- edge relative to this node
---@param strict boolean: optional, defaults to false; if true, this method will raise an
--- error if an edge b/w this and the provided node already exists in the - provided
--- direction
---@error if an edge b/w this and the provided node already exists in the provided
--- direction
function Node:add_edge(node, direction, strict)
  direction = direction or EdgeDirction.default()
  strict = Bool.or_default(strict, false)

  add_edge(self, node, direction, strict)
end

return Node
