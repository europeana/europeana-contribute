# frozen_string_literal: true

require 'faraday_middleware'

class VocabulariesController < ApplicationController
  class << self
    attr_reader :index_options

    def vocabulary_index(**options)
      @index_options = options
    end
  end

  delegate :index_options, to: :class

  def index
    response = http.get(index_options[:url], index_params)
    render json: index_data(response.body).uniq
  end

  protected

  def http
    @http ||= begin
      Faraday.new do |conn|
        conn.request :instrumentation
        conn.request :retry, max: 5, interval: 3, exceptions: [Errno::ECONNREFUSED, EOFError]

        conn.response :json, content_type: /\bjson$/

        conn.options.open_timeout = 5
        conn.options.timeout = 15

        conn.adapter :excon
      end
    end
  end

  def index_params
    index_options[:params].merge(index_options[:query] => index_query)
  end

  def index_query
    params[:q]
  end

  def index_data(json)
    json[index_options[:results]].map do |result|
      result_text = call_or_fetch(index_options[:text], result)
      result_value = call_or_fetch(index_options[:value], result)
      { text: result_text, value: result_value }
    end
  end

  def call_or_fetch(method_name_or_proc_or_key, hash)
    if method_name_or_proc_or_key.respond_to?(:call)
      method_name_or_proc_or_key.call(hash)
    elsif method_name_or_proc_or_key.is_a?(Symbol)
      send(method_name_or_proc_or_key, hash)
    else
      hash[method_name_or_proc_or_key]
    end
  end
end
