require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Prince do
  describe "defaults" do
    let(:pdf) { Prince.new }

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
      Prince.new(:source => 'file.html').sources.should be_an(Array)
    end

    it "should always make :stylesheets an array" do
      Prince.new(:stylesheets => 'file.html').stylesheets.should be_an(Array)
    end
  end

  describe "#command" do
    let(:pdf) { 
      instance = Prince.new
      instance.stub!(:`).and_return('/path/to/prince')
      instance
    }

    context "when no source file is set" do
      it "should raise an error" do
        lambda {
          pdf.command
        }.should raise_error(Prince::SourceError)
      end
    end

    context "when an invalid input type is set" do
      it "should raise an error" do
        pdf.sources = "file.html"
        pdf.input = 'csv'
        lambda {
          pdf.command
        }.should raise_error(Prince::InputError)
      end
    end

    it "should return a properly formatted command string" do
      pdf.source = 'file.html'
      pdf.command.should == '/path/to/prince --input=html file.html -o -'
    end
    
    it "should include multiple sources if specified" do
      pdf.sources = ['file1.html', 'file2.html']
      pdf.command.should == '/path/to/prince --input=html file1.html file2.html -o -'
    end
  end

  describe "#to_stream" do
    before do
      @pdf = Prince.new(:sources => 'file.html')
      @pdf.stub!(:`).and_return('/path/to/prince')
      @io = mock("IO")
      @rendered_pdf = mock("rendered pdf")
      @io.stub!(:close_write)
      @io.stub!(:gets).and_return(@rendered_pdf)
      @io.stub!(:close_read)
      IO.stub!(:popen).and_return(@io)
    end

    it "should run the command as a subprocess" do
      IO.should_receive(:popen).with(@pdf.command, "w+").and_return(@io)
      @pdf.to_stream
    end

    it "should run the command as a subprocess" do
      @pdf.to_stream.should == @rendered_pdf
    end
  end
end
