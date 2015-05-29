module Spree::Fulfillment::Providers::Amazon
  class FbaInventoryReportRequest < PeddlerRequest

    def report
      FbaInventoryReport.new(parsed_response)
    end

    private

    attr_accessor :request_start

    def parsed_response
      @request_start = Time.now
      while report_status != '_DONE_'
        if elapsed > request_timeout
          raise ReportTimeoutError.new 'Processing of "_GET_AFN_INVENTORY_DATA_" report failed to complete in under 20 minutes!'
        end
        sleep(5)
      end
      client(::Peddler::Parser).get_report(report_id)
    end

    def elapsed
      Time.now - request_start
    end

    def request_timeout
      20.minutes
    end

    def report_status
      response = client.get_report_request_list(report_request_id_list: report_request_id)
      generated_report_id_node = response.css("GeneratedReportId")
      @report_id = generated_report_id_node.text if generated_report_id_node.respond_to?(:text) && generated_report_id_node.text.length > 0
      response.css("ReportProcessingStatus").text
    end

    def report_request_id
      @report_request_id ||= request_report
    end

    def request_report
      response = client.request_report('_GET_AFN_INVENTORY_DATA_')
      response.css("ReportRequestId").text
    end

    def client_class
      ::MWS::Reports::Client
    end

    def report_id
      @report_id ||= get_report_id
    end

    def get_report_id
      response = client.get_report_list(report_request_id_list: report_request_id)
      response.css("ReportInfo ReportId").text
    end    

  end

  class ReportTimeoutError < StandardError; end
end
