class View
  require 'builder'
  attr_reader :instance_key


  def initialize(key)
    @instance_key = key
  end

  # Getter for the BAM UI,
  # checks that the build_index_html method hasn't already been run
  def html
    if @index_html != nil
      @index_html
    else
      self.build_index_html
      @index_html
    end
  end

  # Creates the BAM UI as @index_html, which is then returned via View#html
  def build_index_html
    @index_html = ''
    @h = Builder::XmlMarkup.new(:target => @index_html, :indent => 2)

    # Javascript functions printed straight in to the builder object
    # This is a looped request, at the speed of the SPEED constant in BAM.rb
    #
    # Uses the plainjax library, packaged in the /lib/resources/public folder
    #
    # Makes calls to mongerel's /start (when the button is pressed) and /read handlers,
    # passing the @instance_key int as a param
    #
    # This param seperates the various instances of BAM, ensuring they spawn their own runs of the script,
    # and keeping their output seperate.
    @js = "function requestLoop() {
              requestOutput();
              setInterval(requestOutput, #{SPEED});
           }

            function requestOutput() {
              plainajax.request('respurl: read?#{@instance_key}; resultloc: output;')
           }

            function showOutput(text) {
              var defaultDivLabel = $(\"output\");
              defaultDivLabel.innerHTML = text;
           }

            function runScript() {
              plainajax.request('respurl: start?#{@instance_key}; resultloc: metamessage;')
           }"



    @h.html{
      @h.head{
        @h.link("rel"=>"stylesheet", "type"=>"text/css", "href"=>"#{STYLESHEET}")
        @h.script("type" => "text/javascript", "src"=>"#{JS}"){
        }
        @h.script("type" => "text/javascript"){
          @index_html << @js # Putting the javascript functions right in
        }
        @h.title("BAM! - #{SCRIPT}")
      }

      @h.body{
        @h.h1("BAM!")
        @h.h2{
          @h.a("Run #{SCRIPT}", "href" => "#RUN", "onclick" => "runScript(); requestLoop();")
        }
        @h.div("id" => "output"){

        }
        #
        # Uncomment if you like buttons...
        #
        # @h.button("Run Script", "type" => "button", "onclick" => "runScript(); requestLoop();")
        @h.div("id" => "metamessage"){

        }
        #
        # For debugging purposes...
        #
        @h.p("My instance key is #{@instance_key}")
      }
    }

  end

end

