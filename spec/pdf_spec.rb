require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Prince::Pdf do
  describe "defaults" do
    let(:pdf) { Prince::Pdf.new }

    it "should set the executable to whatever is returned by `which prince`" do
      pdf.should_receive(:`).with('which prince').and_return('/path/to/prince')
      pdf.executable.should == '/path/to/prince'
    end

    it "should set the input to html" do
      pdf.input.should == 'html'
    end

    it "should set the stylesheets to an empty array" do
      pdf.stylesheets.should == []
    end

    it "should set the sources to an empty array" do
      pdf.sources.should == []
    end
  end

  describe "passing in options" do
    it "should always make :sources an array" do
      Prince::Pdf.new(:source => 'file.html').sources.should be_an(Array)
    end

    it "should always make :stylesheets an array" do
      Prince::Pdf.new(:stylesheets => 'file.html').stylesheets.should be_an(Array)
    end
  end

  describe "#command" do
    let(:pdf) { 
      instance = Prince::Pdf.new(:sources => ['file.html'])
      instance.stub!(:`).and_return('/path/to/prince')
      instance
    }

    it "should return a properly formatted command string" do
      pdf.command.should == '/path/to/prince --input=html file.html -o -'
    end

    it "should include multiple sources if specified" do
      pdf.sources = ['file1.html', 'file2.html']
      pdf.command.should == '/path/to/prince --input=html file1.html file2.html -o -'
    end
  end
end
