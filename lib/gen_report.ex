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
end
