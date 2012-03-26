require 'socket'

module NetTools

  def self.local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
    ensure
    Socket.do_not_reverse_lookup = orig
  end
end
