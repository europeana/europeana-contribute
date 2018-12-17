# frozen_string_literal: true

require 'faraday_middleware'

class VocabulariesController < ApplicationController
  class << self
    attr_reader :index_options, :show_options

    def vocabulary_index(**options)
      @index_options = options
    end

    def vocabulary_show(**options)
      @show_options = options
    end
  end

  delegate :index_options, :show_options, to: :class

  def index
    response = http.get(index_options[:url], index_params)
    render json: index_data(response.body).uniq
  end

  def show
    response = http.get(show_url, show_params)
    render json: show_data(response.body)
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

  def show_params
    show_options[:params].each_with_object({}) do |(k, v), memo|
      memo[k] = v.is_a?(Proc) ? v.call(show_uri) : v
    end
  end

  def show_uri
    @show_uri ||= URI.parse(params[:uri])
  end

  def show_url
    case show_options[:url]
    when Proc
      show_options[:url].call(show_uri)
    else
      show_options[:url]
    end
  end

  def index_query
    params[:q]
  end

  def index_data(json)
    index_root = index_options[:results] ? json[index_options[:results]] : json
    return [] if index_root.nil?
    index_root.map do |result|
      result_text = call_or_fetch(index_options[:text], result)
      result_value = call_or_fetch(index_options[:value], result)
      { text: result_text, value: result_value }
    end
  end

  def show_data(json)
    result_text = call_or_fetch(show_options[:text], json)
    result_value = show_options.key?(:value) ? call_or_fetch(show_options[:value], json) : show_uri
    { text: result_text, value: result_value }
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
