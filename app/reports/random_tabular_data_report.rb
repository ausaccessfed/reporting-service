class RandomTabularDataReport < TabularReport
  report_type 'random-tabular-data'

  header ['Sentence', 'Number of words', 'Random number']
  footer

  def rows
    (1..100).map do
      s = Faker::Lorem.sentence
      [s, s.split(/\s+/).length, rand(1024 * 1024)]
    end
  end
end
