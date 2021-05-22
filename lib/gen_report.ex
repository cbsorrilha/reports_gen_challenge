defmodule GenReport do
  alias GenReport.Parser

  @base_acc %{
    "all_hours" => %{},
    "hours_per_month" => %{},
    "hours_per_year" => %{}
  }

  def build, do: {:error, "Insira o nome de um arquivo"}
  def build(p) when is_nil(p), do: {:error, "Insira o nome de um arquivo"}

  def build(file_name) do
    # DONE :)
    file_name
    |> Parser.parse_file()
    |> Enum.reduce(@base_acc, fn line, report -> calculate(line, report) end)
  end

  def build_from_many, do: {:error, "Insira uma lista de nomes de arquivos"}

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Insira uma lista de nomes de arquivos"}
  end

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(@base_acc, fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => per_month1,
           "hours_per_year" => per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => per_month2,
           "hours_per_year" => per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    per_month = merge_maps(per_month1, per_month2)
    per_year = merge_maps(per_year1, per_year2)
    build_report(all_hours, per_month, per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> sum_map_values(value1, value2) end)
  end

  defp sum_map_values(value1, value2) when is_map(value1) and is_map(value2) do
    merge_maps(value1, value2)
  end

  defp sum_map_values(value1, value2), do: value1 + value2

  defp calculate([name, hours, _day, month, year], report) do
    all_hours = report["all_hours"]
    per_month = report["hours_per_month"]
    per_year = report["hours_per_year"]

    %{
      "all_hours" => calculate_all_hours(all_hours, name, hours),
      "hours_per_month" => calculate_hours_per_month(per_month, name, month, hours),
      "hours_per_year" => calculate_hours_per_year(per_year, name, year, hours)
    }
  end

  defp calculate_all_hours(all_hours, name, hours) do
    Map.put(all_hours, name, hours + Map.get(all_hours, name, 0))
  end

  defp calculate_hours_per_month(per_month, name, month, hours) do
    current_user_months = Map.get(per_month, name, %{})

    new_user_months =
      Map.put(current_user_months, month, hours + Map.get(current_user_months, month, 0))

    Map.put(per_month, name, new_user_months)
  end

  defp calculate_hours_per_year(per_year, name, year, hours) do
    current_user_years = Map.get(per_year, name, %{})

    new_user_years =
      Map.put(current_user_years, year, hours + Map.get(current_user_years, year, 0))

    Map.put(per_year, name, new_user_years)
  end

  defp build_report(all_hours, per_month, per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => per_month,
      "hours_per_year" => per_year
    }
  end
end
