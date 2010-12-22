class Views
  require 'builder'

  JS = 'public/plainjax.js'
  STYLESHEET = 'public/main.css'
  SCRIPTNAME = 'hello.rb'

  def self.index_html
    if defined? @@index_html
      @@index_html
    else
      self.build_index_html
      @@index_html
    end
  end

  def self.build
    self.build_index_html
  end

  def self.build_index_html
    @@index_html = ''
    @h = Builder::XmlMarkup.new(:target => @@index_html, :indent => 2)

@js = '
function requestLoop() {
  requestOutput();
  setInterval(requestOutput, 300);
}


function requestOutput() {
  plainajax.request(\'respurl: read; resultloc: output;\')
}

function showOutput(text) {
  var defaultDivLabel = $("output");
  defaultDivLabel.innerHTML = text;
}

function runScript() {
  plainajax.request(\'respurl: start; resultloc: metamessage;\')
}'

  @h.html{
    @h.head{
      @h.link("rel"=>"stylesheet", "type"=>"text/css", "href"=>"#{STYLESHEET}")
      @h.script("type" => "text/javascript", "src"=>"#{JS}"){
      }
      @h.script("type" => "text/javascript"){
        @@index_html << @js
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

