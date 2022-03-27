# frozen_string_literal: true

module JpVaccination
  class Vaccination
    attr_reader :name, :period, :deadline, :regular, :interval, :recommended, :type

    def initialize(data)
      @name = data[:name]
      @period = data[:period]
      @regular = data[:regular]
      @type = data[:type]
      @recommended = data[:recommended]
      @deadline = data[:deadline]
      @interval = data[:interval]
    end

    def formal_name
      "#{@name} #{@period}"
    end
  end
end
