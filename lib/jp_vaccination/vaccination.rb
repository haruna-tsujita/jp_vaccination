# frozen_string_literal: true

module JpVaccination
  class Vaccination
    attr_reader :name, :period, :deadline, :regular, :interval, :recommended, :type

    def initialize(data)
      @name = data[:name]
      @period = data[:period]
      @deadline = data[:deadline]
      @interval = data[:interval]
      @regular = data[:regular]
      @recommended = data[:recommended]
      @type = data[:type]
    end
  end
end
