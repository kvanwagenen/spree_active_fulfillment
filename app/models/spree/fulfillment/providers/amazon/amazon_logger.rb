module Spree::Fulfillment::Providers::Amazon
  class AmazonLogger
    
    def initialize()
      @std_logger = Logger.new("log/amazon_requests.log")
      @std_logger.level = Logger::DEBUG
    end
    
    ['unknown','fatal','error','warn','info','debug'].each do |level|
      define_method(level) do |msg, order=nil|
        std_logger.send(level, wrapped_msg(msg, order))
      end
    end
    
    private 
    
    attr_accessor :std_logger
    
    def wrapped_msg(msg, order)
      if order.try(:number)
        order_str = "#{order.try(:number)} - "
      else
        order_str = ""
      end
      "#{order_str}#{msg}"
    end
  end
end