# JpVaccination
It provides data on infant vaccination in Japan. It also processes calculations of recommended and next available dates for vaccination.

These data are based on [the vaccination schedule of the National Institute of Infectious Diseases](https://www.niid.go.jp/niid/ja/schedule.html). Currently, only regular and some optional vaccinations in infancy are covered, but in the future all vaccinations will be covered.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jp_vaccination'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jp_vaccination

## Usage

```ruby
require 'jp_vaccination'
```
### Check vaccination_keys.
You can check the list of [vaccination_keys](#about-vaccination_key) that can be passed as arguments.

`JpVaccination.vaccination_keys`

```ruby
pp JpVaccination.vaccination_keys

=> [{ 'ヒブ １回目' => 'hib_1' },
    { 'ヒブ ２回目' => 'hib_2' },
    { 'ヒブ ３回目' => 'hib_3' },
    { 'ヒブ ４回目' => 'hib_4' },
    { 'Ｂ型肝炎 １回目' => 'hepatitis_B_1' },
    { 'Ｂ型肝炎 ２回目' => 'hepatitis_B_2' },
    { 'Ｂ型肝炎 ３回目' => 'hepatitis_B_3' },
    { 'ロタウイルス １回目' => 'rotavirus_1' },
    { 'ロタウイルス ２回目' => 'rotavirus_2' },
    { 'ロタウイルス ３回目' => 'rotavirus_3' },
    { '小児用肺炎球菌 １回目' => 'pneumococcus_1' },
    { '小児用肺炎球菌 ２回目' => 'pneumococcus_2' },
    { '小児用肺炎球菌 ３回目' => 'pneumococcus_3' },
    { '小児用肺炎球菌 ４回目' => 'pneumococcus_4' },
    { '４種混合 第１期 １回目' => 'DPT_IPV_1' },
    { '４種混合 第１期 ２回目' => 'DPT_IPV_2' },
    { '４種混合 第１期 ３回目' => 'DPT_IPV_3' },
    { '４種混合 第１期 ４回目' => 'DPT_IPV_4' },
    { '２種混合 第２期' => 'DT_1' },
    { 'ＢＣＧ ' => 'BCG_1' },
    { '麻しん・風しん混合 第１期' => 'MR_1' },
    { '麻しん・風しん混合 第２期' => 'MR_2' },
    { '水痘 １回目' => 'chickenpox_1' },
    { '水痘 ２回目' => 'chickenpox_2' },
    { 'おたふくかぜ １回目' => 'mumps_1' },
    { 'おたふくかぜ ２回目' => 'mumps_2' },
    { '日本脳炎 第１期 １回目' => 'Japanese_encephalitis_1' },
    { '日本脳炎 第１期 ２回目' => 'Japanese_encephalitis_2' },
    { '日本脳炎 第１期 ３回目' => 'Japanese_encephalitis_3' },
    { '日本脳炎 第２期' => 'Japanese_encephalitis_4' }]

```

### Access to vaccination data.
Pass the argument as a string for the [vaccination_key](#about-vaccination_key).

`JpVaccination.find(vaccination_key)`

```ruby
chickenpox_1st = JpVaccination.find('chickenpox_1')

chickenpox_1st.name        # => "水痘"
chickenpox_1st.period      # => "１回目"
chickenpox_1st.regular     # => true
chickenpox_1st.type        # => "生ワクチン"
chickenpox_1st.recommended # => {:month=>12}
chickenpox_1st.deadline    # => {:date_type=>"month", :start=>12, :end=>15, :less_than=>true}
chickenpox_1st.interval    # => nil

# name + period
chickenpox_1st.formal_name  # => "水痘 １回目"
```
Example data.
|column|data|example|title|
|-|-|-|-|
name |String|"水痘"|予防接種名|
period|String|"２回目"|期間|
regular|true/false|true|定期/任意|
type[^1]|String|"生ワクチン"|種類|
recommended|Hash|{ month: 18 }| 推奨接種月齢
deadline[^2]|Hash|{<br> date_type: "month",<br>start: 15,<br> end: 36,<br> less_than: true<br>}|接種期日|
interval[^2]|Hash|{ <br>date_type: "month",<br> start: 3,<br> end: 12 <br>}|接種間隔|

[^1]:`nil except for live vaccines.`
[^2]:5~36 months:{date_type:"month",start:15,end:36},`less_than:true` is less than.
`less_than:false` is below.

### Calculate all recommended dates of vaccination
`JpVaccination.recommended_days(birthday, convert_to_strings)`

default convert_to_string: nil

```rb
birthday = '2022-03-01'
pp JpVaccination.recommended_days(birthday, convert_to_strings = true)
# default convert_to_string: nil

=> [{:name=>"ヒブ １回目", :date=>"2022-05-01"},
    {:name=>"ヒブ ２回目", :date=>"2022-06-01"},
    {:name=>"ヒブ ３回目", :date=>"2022-07-01"},
    {:name=>"ヒブ ４回目", :date=>"2023-03-01"},
    {:name=>"Ｂ型肝炎 １回目", :date=>"2022-05-01"},
    {:name=>"Ｂ型肝炎 ２回目", :date=>"2022-06-01"},
    {:name=>"Ｂ型肝炎 ３回目", :date=>"2022-10-01"},
    {:name=>"ロタウイルス １回目", :date=>"2022-05-01"},
    {:name=>"ロタウイルス ２回目", :date=>"2022-06-01"},
    {:name=>"ロタウイルス ３回目", :date=>"2022-07-01"},
    {:name=>"小児用肺炎球菌 １回目", :date=>"2022-05-01"},
    {:name=>"小児用肺炎球菌 ２回目", :date=>"2022-06-01"},
    {:name=>"小児用肺炎球菌 ３回目", :date=>"2022-07-01"},
    {:name=>"小児用肺炎球菌 ４回目", :date=>"2023-03-01"},
    {:name=>"４種混合 第１期 １回目", :date=>"2022-06-01"},
    {:name=>"４種混合 第１期 ２回目", :date=>"2022-07-01"},
    {:name=>"４種混合 第１期 ３回目", :date=>"2022-08-01"},
    {:name=>"４種混合 第１期 ４回目", :date=>"2023-03-01"},
    {:name=>"２種混合 第２期", :date=>"2033-03-01"},
    {:name=>"ＢＣＧ ", :date=>"2022-08-01"},
    {:name=>"麻しん・風しん混合 第１期", :date=>"2023-03-01"},
    {:name=>"麻しん・風しん混合 第２期", :date=>"2027-04-01〜2028-04-01"},
    {:name=>"水痘 １回目", :date=>"2023-03-01"},
    {:name=>"水痘 ２回目", :date=>"2023-09-01"},
    {:name=>"おたふくかぜ １回目", :date=>"2023-03-01"},
    {:name=>"おたふくかぜ ２回目", :date=>"2027-04-01〜2028-04-01"},
    {:name=>"日本脳炎 第１期 １回目", :date=>"2025-03-01"},
    {:name=>"日本脳炎 第１期 ２回目", :date=>"2025-04-01"},
    {:name=>"日本脳炎 第１期 ３回目", :date=>"2026-03-01"},
    {:name=>"日本脳炎 第２期", :date=>"2031-03-01"}]
```
### Sort recommended vaccination dates in ascending order
`JpVaccination.recommended_schedules(birthday, convert_to_strings = nil)`

You can turn Date into String by setting `convert_to_strings` to true

```rb
birthday = '2022-03-01'
pp JpVaccination.recommended_schedules(birthday, convert_to_strings = true)
# default convert_to_string: nil

=> {"2022-05-01"=>["ヒブ １回目", "ロタウイルス １回目", "小児用肺炎球菌 １回目", "Ｂ型肝炎 １回目"],
    "2022-06-01"=>["ヒブ ２回目", "ロタウイルス ２回目", "小児用肺炎球菌 ２回目", "４種混合 第１期 １回目", "Ｂ型肝炎 ２回目"],
    "2022-07-01"=>["ヒブ ３回目", "ロタウイルス ３回目", "小児用肺炎球菌 ３回目", "４種混合 第１期 ２回目"],
    "2022-08-01"=>["４種混合 第１期 ３回目", "ＢＣＧ "],
    "2022-10-01"=>["Ｂ型肝炎 ３回目"],
    "2023-03-01"=>["おたふくかぜ １回目", "ヒブ ４回目", "小児用肺炎球菌 ４回目", "水痘 １回目", "麻しん・風しん混合 第１期", "４種混合 第１期 ４回目"],
    "2023-09-01"=>["水痘 ２回目"],
    "2025-03-01"=>["日本脳炎 第１期 １回目"],
    "2025-04-01"=>["日本脳炎 第１期 ２回目"],
    "2026-03-01"=>["日本脳炎 第１期 ３回目"],
    "2027-04-01〜2028-03-31"=>["おたふくかぜ ２回目", "麻しん・風しん混合 第２期"],
    "2031-03-01"=>["日本脳炎 第２期"],
    "2033-03-01"=>["２種混合 第２期"]}
```


`JpVaccination.recommended_schedules(birthday, nil)` or
`JpVaccination.recommended_schedules(birthday)`
```ruby
pp JpVaccination.recommended_schedules('2022-03-01')
=> {#<Date: 2022-05-01 ((2459701j,0s,0n),+0s,2299161j)>=>["小児用肺炎球菌 １回目", "ヒブ １回目", "ロタウイルス １回目", "Ｂ型肝炎 １回目"],…
```

### Calculate the next available vaccination date from the date of the previous vaccination.
`JpVaccination.next_day(vaccination_key, last_time)`

```rb
pp JpVaccination.next_day('hepatitis_B_2', '2020-04-01')

=> {:name=>"Ｂ型肝炎 ２回目", :date=>#<Date: 2020-04-28 ((2458968j,0s,0n),+0s,2299161j)>}
```

If you want to find the date of the first vaccination, in short, the last character of the vaccination_key is 1, enter the date of birth in last_time.

`JpVaccination.next_day(vaccination_1, birthday)`
```ruby
birthday = '2022-02-01'
pp JpVaccination.next_day('hepatitis_B_1', birthday)

=> {:name=>"Ｂ型肝炎 １回目", :date=>#<Date: 2022-04-01 ((2458968j,0s,0n),+0s,2299161j)>}
```

### Argument Error
If the [vaccination_key](#about-vaccination_key) is incorrect, the following error occurs.
```
# hepatitis_B_4 is incorrect.

puts JpVaccination.next_day(vaccination_key: 'hepatitis_B_4', last_time: '2020-04-01')

# error
jp_vaccination/lib/jp_vaccination.rb:99:in `output_argument_error': The vaccination_key 'hepatitis_B_4' doesn't exist. (ArgumentError)
```

## About vaccination_key
The key formation is `(vaccination's English translation)_(period-number)`.

Each vaccination and corresponding key is as follows.

|vaccination_key|name|period|
|---|-----|------|
|hib_1|ヒブ|１回目|
|hib_2|ヒブ|２回目|
|hib_3|ヒブ|３回目|
|hib_4|ヒブ|４回目|
|hepatitis_B_1|Ｂ型肝炎|１回目|
|hepatitis_B_2|Ｂ型肝炎|２回目|
|hepatitis_B_3|Ｂ型肝炎|３回目|
|rotavirus_1|ロタウイルス|１回目|
|rotavirus_2|ロタウイルス|２回目|
|rotavirus_3|ロタウイルス|３回目|
|pneumococcus_1|小児用肺炎球菌|１回目|
|pneumococcus_2|小児用肺炎球菌|２回目|
|pneumococcus_3|小児用肺炎球菌|３回目|
|pneumococcus_4|小児用肺炎球菌|４回目|
|DPT_IPV_1|４種混合|第１期 １回目|
|DPT_IPV_2|４種混合|第１期 ２回目|
|DPT_IPV_3|４種混合|第１期 ３回目|
|DPT_IPV_4|４種混合|第２期|
|DT_1|２種混合|第２期|
|BCG_1|ＢＣＧ|-|
|MR_1|麻しん・風しん混合|第１期|
|MR_2|麻しん・風しん混合|第２期|
|chickenpox_1|水痘|１回目|
|chickenpox_2|水痘|２回目|
|mumps_1|おたふくかぜ|１回目|
|mumps_2|おたふくかぜ|２回目|
|Japanese_encephalitis_1|日本脳炎|第１期 １回目|
|Japanese_encephalitis_2|日本脳炎|第１期 ２回目|
|Japanese_encephalitis_3|日本脳炎|第１期 ３回目|
|Japanese_encephalitis_4|日本脳炎|第２期|

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/napple29/jp_vaccination. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/napple29/jp_vaccination/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JpVaccination project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/napple29/jp_vaccination/blob/master/CODE_OF_CONDUCT.md).
