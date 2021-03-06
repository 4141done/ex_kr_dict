defmodule KrDict.Stemming.SeattleStemCheck do
  @test_text "미국 동부와 퓨젯사운드 지방을 연결하는 첫 철도는 1883년 노던퍼시픽 철도가 타코마로 서비스를 시작하면서 완성되었다. 철도는 정착자들을 데려왔고 지역의 자연 자원들을 위한 국내적 시장들을 열었다. 새로운 시장들은 지역의 목재와 종이 산업들의 거대한 확장으로 이끌었다. 1889년 화재가 시애틀의 비지니스 구역 대부분을 파괴시켰다. 그럼에도 불구하고, 도시의 인구는 1890년 43,000명으로 자라났다."
  @expected [
    {"미국", "미국"},
    {"동부", "동부와"},
    {"퓨젯사운드", "퓨젯사운드"},
    {"지방", "지방을"},
    {"연걸하다", "연결하는"},
    {"첫", "첫"},
    {"철도", "철도는"},
    {"1883년", "1883년"},
    {"노던퍼시픽", "노던퍼시픽"},
    {"철도", "철도가"},
    {"타코마", "타코마로"},
    {"서비스", "서비스를"},
    {"시작하다", "시작하면서"},
    {"완성되다", "완성되었다."},
    {"철도", "철도는"},
    {"정착자", "정착자들을"},
    {"데려오다", "데려왔고"},
    {"지역", "지역의"},
    {"자연", "자연"},
    {"자원", "자원들을"},
    # ??
    {"위하다", "휘한"},
    {"국내적", "국내적"},
    {"시장", "시장들을"},
    {"열다", "열었다."},
    {"새롭다", "새로운"},
    {"시장", "시장들은"},
    {"지역", "지역의"},
    {"목재", "목재와"},
    {"종이", "종이"},
    {"선업", "산업들의"},
    {"거대하다", "거대한"},
    {"확장", "확장으로"},
    {"이끌다", "이끌었다."},
    {"1889년", "1889년"},
    {"화재", "화재가"},
    {"시애틀", "시애틀의"},
    {"비지니스", "비지니스"},
    {"구역", "구역"},
    {"대부분", "대부분을"},
    {"파괴시키다", "파괴시켰다."},
    {"그럼에도", "그럼에도"},
    {"불구하다", "불구하고,"},
    {"도시", "도시의"},
    {"인구", "인구는"},
    {"1890년", "1890년"},
    {"43,000명", "43,000명으로"},
    {"자라나다", "자라났다."}
  ]

  alias KrDict.Stemming.Stemmer

  def check do
    stemmed =
      @test_text
      |> String.split(" ")
      |> Enum.map(&Stemmer.naive_dictionary/1)

    results =
      stemmed
      |> Enum.reduce({0, []}, fn stem_result, {error_count, errored} ->
        case Enum.member?(@expected, stem_result) do
          false ->
            {error_count + 1, [stem_result | errored]}

          _ ->
            {error_count, errored}
        end
      end)

    %{
      stem_results: stemmed,
      error_report: results,
      accuracy: (length(@expected) - elem(results, 0)) / length(@expected)
    }
  end
end
