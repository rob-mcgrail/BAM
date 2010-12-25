class View
  require 'builder'
  attr_reader :hash
  @@id = 0
  JS = 'public/plainjax.js'
  STYLESHEET = 'public/main.css'
  SCRIPTNAME = 'hello.rb'
  SPEED = '300'

  def self.new_session

  end

  def initialize
    @@id += 1
    @instance_id = @@id
  end

  def html
    if @index_html != nil
      @index_html
    else
      self.build_index_html
      @index_html
    end
  end



  def build_index_html
    @index_html = ''
    @h = Builder::XmlMarkup.new(:target => @index_html, :indent => 2)

    # Javascript functions printed straight in to the builder object
    @js = "function requestLoop() {
              requestOutput();
              setInterval(requestOutput, #{SPEED});
           }

            function requestOutput() {
              plainajax.request('respurl: read?#{@instance_id}; resultloc: output;')
           }

            function showOutput(text) {
              var defaultDivLabel = $(\"output\");
              defaultDivLabel.innerHTML = text;
           }

            function runScript() {
              plainajax.request('respurl: start?#{@instance_id}; resultloc: metamessage;')
           }"



    @h.html{
      @h.head{
        @h.link("rel"=>"stylesheet", "type"=>"text/css", "href"=>"#{STYLESHEET}")
        @h.script("type" => "text/javascript", "src"=>"#{JS}"){
        }
        @h.script("type" => "text/javascript"){
          @index_html << @js # Putting the javascript functions right in
        }
        @h.title("BAM! - #{SCRIPTNAME}")
      }

      @h.body{
        @h.h1("BAM!")
        @h.h2{
          @h.a("Run #{SCRIPTNAME}", "href" => "#RUN", "onclick" => "runScript(); requestLoop();")
        }
        @h.div("id" => "output"){

        }
        @h.button("Run Script", "type" => "button", "onclick" => "runScript(); requestLoop();")
        @h.div("id" => "metamessage"){

        }
      }
    }

  end

end

