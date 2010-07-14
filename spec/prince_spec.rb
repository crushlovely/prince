require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Prince do
  describe "defaults" do
    let(:pdf) { Prince.new }

    it "should set the executable to whatever is returned by `which prince`" do
      pdf.should_receive(:`).with('which prince').and_return('/path/to/prince')
      pdf.executable.should == '/path/to/prince'
    end

    it "should set the input to html" do
      pdf.input_format.should == 'html'
    end

    it "should set the stylesheets to an empty array" do
      pdf.stylesheets.should == []
    end
  end

  describe "passing in options" do
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

    context "when no executable is available" do
      it "should raise an error" do
        pdf.stub!(:`).and_return('')
        lambda {
          pdf.command
        }.should raise_error(Prince::ExecutableError)
      end
    end

    context "when no source file is set" do
      it "should raise an error" do
        lambda {
          pdf.command
        }.should raise_error(Prince::SourceError)
      end
    end

    context "when an invalid input type is set" do
      it "should raise an error" do
        pdf.source = "file.html"
        pdf.input_format = 'csv'
        lambda {
          pdf.command
        }.should raise_error(Prince::InputError)
      end
    end

    it "should return a properly formatted command string" do
      pdf.source = 'file.html'
      pdf.command.should == '/path/to/prince --input=html --silent - -o -'
    end
    
    it "should include multiple sources if specified" do
      pdf.source = 'file1.html'
      pdf.command.should == '/path/to/prince --input=html --silent - -o -'
    end
  end

  describe "#to_pdf" do
    before do
      @pdf = Prince.new(:source => '<h1>Hello World!</h1>')
      @pdf.stub!(:`).and_return('/path/to/prince')
      @io = mock("IO")
      @pdf_stream = mock("pdf_stream")
      @pdf_file = mock("pdf_file")
      @io.stub!(:close_write)
      @io.stub!(:puts)
      @io.stub!(:gets).and_return(@pdf_stream)
      @io.stub!(:close_read)
      @io.stub!(:close).and_return(@pdf_file)
      IO.stub!(:popen).and_return(@io)
    end

    shared_examples_for "an output method" do
      it "should run the command as a subprocess" do
        IO.should_receive(:popen).with(@pdf.command, "w+").and_return(@io)
        do_method
      end

      it "should pass the source attribute into the standard input" do
        @io.should_receive(:puts).with('<h1>Hello World!</h1>')
        do_method
      end
    end

    context "when passing nothing in" do
      def do_method
        @pdf.to_pdf
      end

      it_should_behave_like "an output method"

      it "should close the write out" do
        @io.should_receive(:close_write)
        do_method
      end

      it "should read the object's complete contents out into a local variable" do
        @io.should_receive(:gets).with(nil)
        do_method
      end

      it "should close the read out" do
        @io.should_receive(:close_read)
        do_method
      end

      it "should return the rendered pdf as a stream" do
        do_method.should == @pdf_stream
      end
    end

    context "when passing a filename in" do
      before do
        @pdf.output_file = 'test.pdf'
      end

      def do_method
        @pdf.to_pdf
      end

      it_should_behave_like "an output method"

      it "should return the rendered pdf as a stream" do
        do_method.should == @pdf_file
      end
    end
  end
end
