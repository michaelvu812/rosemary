require 'webmock/rspec'
require 'osm-client'

describe 'OpenStreetMap' do

  before do
    WebMock.disable_net_connect!
  end

  let :osm do
    OpenStreetMap.new
  end

  describe '::Node' do

    def valid_fake_node
      node=<<-EOF
      <osm>
       <node id="123" lat="51.2" lon="13.4" version="142" changeset="12" user="fred" uid="123" visible="true" timestamp="2005-07-30T14:27:12+01:00">
         <tag k="note" v="Just a node"/>
       </node>
      </osm>
      EOF
    end

    describe '#find:' do

      it "should build a Node from API response via get_object" do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/1234").to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
        node = osm.find_element('node', 1234)
        node.class.should eql OpenStreetMap::Node
      end

      it "should build a Node from API response via get_node" do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/1234").to_return(:status => 200, :body => valid_fake_node, :headers => {'Content-Type' => 'application/xml'})
        node = osm.find_node(1234)
        node.class.should eql OpenStreetMap::Node
      end

      it "should raise an Gone error, when a node has been deleted" do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/1234").to_return(:status => 410, :body => '', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          node = osm.find_node(1234)
        }.should raise_error(OpenStreetMap::Gone)
      end

      it "should raise an NotFound error, when a node cannot be found" do
        stub_request(:get, "http://www.openstreetmap.org/api/0.6/node/1234").to_return(:status => 404, :body => '', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          node = osm.find_node(1234)
        }.should raise_error(OpenStreetMap::NotFound)
      end
    end

    describe '#create:' do

      let :osm do
        OpenStreetMap.new(OpenStreetMap::BasicAuthClient.new('a_username', 'a_password'))
      end

      it "should create a new Node from given attributes" do
        stub_request(:put, "http://www.openstreetmap.org/api/0.6/node/create").to_return(:status => 200, :body => '123', :headers => {'Content-Type' => 'text/plain'})
        node = OpenStreetMap::Node.new()
        new_id = osm.save(node)
      end

      it "should not create a Node with invalid xml but raise BadRequest" do
        stub_request(:put, "http://www.openstreetmap.org/api/0.6/node/create").to_return(:status => 400, :body => 'The given node is invalid', :headers => {'Content-Type' => 'text/plain'})
        lambda {
          node = OpenStreetMap::Node.new(:id => nil)
          new_id = osm.save(node)
        }.should raise_error(OpenStreetMap::BadRequest)

      end

    end

    describe '#update:' do
    end

    describe '#delete:' do
    end
  end
end