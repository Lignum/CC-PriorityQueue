--[[
  Creates a priority queue node, taking a value for the node to contain,
  as well as a priority (key).
]]
local function Node(value, priority)
  return {
    value = value,
    key = priority,
    index = nil
  }
end

--[[
  Creates a priority queue. If a table of Nodes is given as a first parameter,
  a priority queue containing these nodes will be constructed in O(n) time.

  Otherwise, the priority queue will be created in constant time.
]]
local function PriorityQueue(nodes)
  if nodes ~= nil and type(nodes) ~= "table" then
    return error("wrong argument #1: expected table, got " .. type(nodes))
  end

  local self = {}

  local heap = {}
  local heapSize = 0

  if nodes ~= nil then
    for i=1,#nodes do
      heap[i] = nodes[i]
      heap[i].index = i
    end
  end

  local function left(i) return 2 * i end
  local function right(i) return 2 * i + 1 end
  local function parent(i) return math.floor(i / 2) end

  local function swap(a, b)
    local aNode = heap[a]
    local bNode = heap[b]
    heap[b] = aNode
    aNode.index = b
    heap[a] = bNode
    bNode.index = a
  end

  local function maxHeapify(i)
    local l = left(i)
    local r = right(i)

    local largest

    if l <= heapSize and heap[l].key > heap[i].key then
      largest = l
    else
      largest = i
    end

    if r <= heapSize and heap[r].key > heap[largest].key then
      largest = r
    end

    if largest ~= i then
      swap(i, largest)
      return maxHeapify(largest)
    end
  end

  local function buildMaxHeap(nodes)
    local len = #nodes
    heapSize = len

    for i=math.floor(len/2),1,-1 do
      maxHeapify(i)
    end
  end

  -- Heap construction
  if nodes ~= nil then
    buildMaxHeap(nodes)
  end

  -- Heap operations

  --[[
    Returns the maximum element in the priority queue. O(1).

    If there is no maximum element, the function returns nil.
  ]]
  function self.findMax()
    return heap[1]
  end

  --[[
    Returns the maximum element in the priority queue and removes it. O(log n).

    If there is no maximum element, the functions throws a "heap underflow" error.
  ]]
  function self.extractMax()
    if heapSize < 1 then
      return error("heap underflow", 2)
    end

    local max = self.findMax()
    heap[1] = heap[heapSize]
    heapSize = heapSize - 1
    maxHeapify(1)
    return max
  end

  --[[
    Increases the priority (key) of an element in the priority queue.
  ]]
  function self.increaseKey(node, priority)
    if type(node) ~= "table" then
      return error("wrong argument #1: expected table, got " .. type(node))
    end

    if priority < node.key then
      return error("priority too small")
    end

    node.key = priority

    while node.index > 1 and heap[parent(node.index)].key < node.key do
      swap(node.index, parent(node.index))
      node.index = parent(node.index)
    end
  end

  --[[
    Inserts an element with a specific priority into the priority queue. O(log n).
  ]]
  function self.insert(node)
    if type(node) ~= "table" then
      return error("wrong argument #1: expected table, got " .. type(node))
    end

    local p = node.key
    heapSize = heapSize + 1
    node.key = -math.huge
    node.index = heapSize
    heap[heapSize] = node
    return self.increaseKey(heap[heapSize], p)
  end

  --[[
    Creates a sorted list from the priority queue. O(n log n).
    This will remove all elements in the priority queue!!
  ]]
  function self.toSortedList()
    local list = {}

    for i=heapSize,1,-1 do
      list[#list + 1] = self.extractMax().value
    end

    return list
  end

  return self
end

--[[
  Sorts a list. O(n log n) time, O(n) space.
]]
local function heapSort(list)
  local n = #list

  if type(list) ~= "table" then
    return error("wrong argument #1: expected table, got " .. type(list))
  end

  local nodes = {}

  for _,v in pairs(list) do
    nodes[#nodes + 1] = Node(v, v)
  end

  local Q = PriorityQueue(nodes)

  for i=n,1,-1 do
    nodes[i] = Q.extractMax().value
  end

  return nodes
end

return {
  Node = Node,
  PriorityQueue = PriorityQueue,
  heapSort = heapSort
}