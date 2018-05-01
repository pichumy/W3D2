class PolyTreeNode
  def initialize(value)
    @value = value
    @parent = nil
    @children = []
  end

  def parent=(parent)
    old_parent = @parent
    old_parent.children.delete(self) unless old_parent.nil?
    @parent = parent
    @parent.children << self unless @parent.nil?
  end

  def parent
    @parent
  end

  def children
    @children
  end

  def value
    @value
  end


  def add_child(child_node)
    child_node.parent = self
  end

  def remove_child(child_node)
    raise "Child has no parent!" unless child_node.parent
    child_node.parent = nil
  end

  def dfs(target)
    return self if value == target

    children.each do |child|
      node = child.dfs(target)
      return node unless node.nil?
    end

    nil
  end


  def wtf
   p "wtf"
 end

  def trace_path_back
    path = []
    curr_node = self
    until curr_node.nil?
      path << curr_node.value
      curr_node = curr_node.parent
    end
    path.reverse
  end

  def bfs(target)
    queue = [self]
    until queue.empty?
      node = queue.shift
      return node if target == node.value
      node.children.each do |child|
        queue << child
      end
    end
    nil
  end
end
