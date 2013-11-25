#!/opt/chef/embedded/bin/ruby

=begin
Have a cacti tree of the following format, all nodes:
Default Tree
+Host: Localhost
+Pod_1
|+Device1
||+Ethernet1/1
||+Ethernet1/2
|+Device2
||+Ethernet1/1
||+Ethernet1/2
+Pod_2
 |+Device3
 ||+Ethernet1/1
 ||+Ethernet1/2
 |+Device4
 : 

Now, find the correct graphs to place under each item.
=end

# Cacti cli path
ccli = '/home/cacti/cacti/cli'

host = Hash.new

#
# Get info on each host
#
IO.popen("php #{ccli}/add_graphs.php --list-hosts") { |cmd|
  cmd.each { |line|
    (id, hostname, template, *description) = line.chomp.split(/\s+/)
    next if id == "Known" or id.nil? or id.empty?
    host[id]                = Hash.new
    host[id]['hostname']    = hostname
    host[id]['template']    = template
    host[id]['description'] = description.join(' ')
  }
}

node = Hash.new

#
# Get info on existing tree
# - assumes full structure already exists, graphs just need to be
#   placed under interface nodes
#
IO.popen("php #{ccli}/add_tree.php --list-nodes --tree-id=1") { |cmd|
  cmd.each { |line|
    (type, id, parentid, title, *attribs) = line.chomp.split(/\s+/)
    next if type == "Known" or type == "id" or type.nil? or type.empty?
    node[id]             = Hash.new
    node[id]['type']     = type
    node[id]['parentid'] = parentid
    node[id]['title']    = title
    node[id]['attribs']  = attribs.join(' ')
  }
}


graphs = Hash.new
# Get info on existing graphs
host.keys.each { |hostid|
  graphs[hostid] = Hash.new
  IO.popen("php #{ccli}/add_tree.php --list-graphs --host-id=#{hostid}") { |graph|
    graph.each { |line|
      (id, name, template) = line.chomp.split(/\t+/)
      next if id.nil? or id.start_with?("Known") or id.empty?
      graphs[hostid][id]             = Hash.new
      graphs[hostid][id]['name']     = name
      graphs[hostid][id]['template'] = template
    }
  }
#  puts graphs[hostid]
}

# host.keys.each { |hostid|
#   puts hostid
#   puts host[hostid]
#   print "Hostname #{host[hostid]['hostname']}\n"
#   unless graphs[hostid].nil?
#     graphs[hostid].keys.each { |gid|
#     # graphs[hostid].each { |gid, subhash|
#       print "  #{ graphs[hostid][gid]['name'] }\n"
#     }
#   end
# }



# 5.times { puts %x{uuidgen} }
