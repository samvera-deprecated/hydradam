require 'spec_helper'
describe "PBCore" do
  it "should draw a graph" do


    # doc.pbcoreCreator would return []

    # if doc.pbcoreCreator had a statement then it returns a list of RDFStatementProxies 

    # when a node is called on it, instantiate a b-node and add a statement to the graph [graph, pbcoreCreator, b-node]
    # and add a statement to the bnode [bnode, RDF::PBCore.creator, 'Justin']
    # this could raise an error if there is more than one pbcoreCreator
    # doc.pbcoreCreator.creator = 'Justin'

    # This wouldn't have any ambiguity
    # doc.pbcoreCreator.first.creator = 'Justin'

   
    # doc.programmer is an alias to doc.pbcoreCreator.where(creatorRole: 'Programmer')


    graph = RDF::Graph.new
    bnode = RDF::Node.new
    graph << RDF::Statement.new(bnode, RDF::PBCore.creator, 'Justin')
    graph << RDF::Statement.new(bnode, RDF::PBCore.creatorRole, 'Programmer')
    graph << RDF::Statement.new(RDF::URI('info:fedora/sufia:999'), RDF::PBCore.pbcoreCreator, bnode)

    puts graph.dump(:ntriples)

  end

end
