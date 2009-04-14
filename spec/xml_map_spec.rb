require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Babelicious
  
  describe XmlMap do 
    
    before(:each) do 
      @node = mock("Xml::Document::Node", :content => "baz")
      @source = mock("Xml::Document", :find => [@node])
      @path_translator = PathTranslator.new("foo/bar")
      @xml_map = XmlMap.new(@path_translator)
    end
    
    describe "#value_from" do 
      
      it "should map value of element in path" do 
        @xml_map.value_from(@source).should == "baz"
      end
      
    end
    
    describe "#map_from" do 
      
      before(:each) do
        XML::Node.stub!(:new).and_return(@xml_node = mock("XML::Node", :empty? => false, :<< => nil))
        @target_xml = mock("XML::Document", :root => nil, :find => [@xml_node], :root= => nil)
      end
      
      def do_process 
        @xml_map.map_from(@target_xml, 'foo')
      end 

      it "should set root element in xml" do 
        during_process { 
          @target_xml.should_receive(:root=).with(@xml_node)
        }
      end
      
      describe "when node is updated" do 

        it "should set value in target node" do 
          during_process { 
            @xml_node.should_receive(:<<).with("foo")
          }
        end
      end
      
    end

    describe "functional tests" do 
      
      describe "when node is not updated" do 
        
        before(:each) do 
          @xml_target = XML::Document.new
          @target_xml.stub!(:find).and_return([])
          @new_node = mock(@xml_node = mock("XML::Node", :empty? => false, :<< => nil))
        end

        def do_process
          @xml_map.map_from(@xml_target, 'baz')
        end 
        
        it "should populate parent nodes of target child" do 
          after_process { 
            @xml_target.to_s.should =~ /<foo>/
          }
        end

        it "should populate target child node" do 
          after_process { 
            @xml_target.to_s.should =~ /<bar>baz/
          }
        end
      end
        
    end
  end

end

