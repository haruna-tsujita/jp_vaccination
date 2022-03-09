# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/jp_vaccination'
require_relative '../lib/jp_vaccination/vaccination'

class JpVaccination::VaccinationTest < Minitest::Test
  def test_vaccination_key_exists
    vaccination = JpVaccination.find('rotavirus_2')
    assert_equal vaccination.name, 'ロタウイルス'
    assert_equal vaccination.period, '２回目'
    assert_equal vaccination.regular, true
    assert_nil vaccination.type
    assert_equal vaccination.recommended, { "month": 3 }
    assert_equal vaccination.deadline, {
      "date_type": 'day',
      "start": nil,
      "end": 168,
      "less_than": true
    }
    assert_equal vaccination.interval, {
      "date_type": 'week',
      "start": 4,
      "end": nil,
      "less_than": true
    }
    assert_equal vaccination.formal_name, 'ロタウイルス ２回目'
  end

  def test_formal_name
    vaccination = JpVaccination.find('mumps_1')
    assert_equal vaccination.formal_name, 'おたふくかぜ １回目'
  end
end
