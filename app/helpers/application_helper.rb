module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_add_leaf name, f, options={}
    leaf = Leaf.new
    id = leaf.object_id
    fields = f.fields_for(:leaves, leaf, child_index: id) do |builder|
      render('leaf_fields', leaf: builder)
    end
    classes = 'add_leaf ' + options[:class]
    link_to(name, '#', class: classes, data: { id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_add_quire_leaf name, f, options={}
    quire_leaf = QuireLeaf.new
    quire_leaf.build_leaf
    id = quire_leaf.object_id
    fields = f.fields_for(:quire_leaves, quire_leaf, child_index: id) do |builder|
      render('quire_leaf_fields', quire_leaf: builder)
    end
    classes = 'add_quire_leaf ' + options[:class]
    link_to(name, '#', class: classes, data: { id: id, fields: fields.gsub("\n", "")})
  end

  def shorten s, limit=60
    return s if s.blank? || s.size <= limit
    tail = 10
    head = limit - (tail + 3)
    sprintf "%s...%s", s[0,head], s[-tail..-1]
  end
end
