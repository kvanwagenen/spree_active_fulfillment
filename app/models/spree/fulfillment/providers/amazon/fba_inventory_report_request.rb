module Spree::Fulfillment::Providers::Amazon
  class FbaInventoryReportRequest < PeddlerRequest

    def initialize(opts)
      @load_most_recent = opts[:load_most_recent] || false
    end

    def report
      FbaInventoryReport.new(parsed_response)
    end

    private

    attr_reader :request_start, :load_most_recent

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
      if load_most_recent && most_recent_report_id
        most_recent_report_id
      else
        response = client.get_report_list(report_request_id_list: report_request_id)
        response.css("ReportInfo ReportId").first.text
      end
    end

    def most_recent_report_id
      report = completed_reports.sort_by{|report| report[:available_date]}.last
      @most_recent_report_id ||= report && report[:report_id] ? report[:report_id] : nil
    end

    def completed_reports
      recent_report_list.css("ReportInfo").map do |report|
        {
          report_id: report.css("ReportId").text, 
          available_date: parse_amazon_date(report.css("AvailableDate").text)
        }
      end
    end

    def recent_report_list
      client.get_report_list(
        report_type_list: '_GET_AFN_INVENTORY_DATA_', 
        available_from_date: (DateTime.now - 7.days).iso8601
      )
    end

    def parse_amazon_date(date_string)
      DateTime.strptime(date_string, "%Y-%m-%dT%H:%M:%S%z")
    end

  end

  class ReportTimeoutError < StandardError; end
end
