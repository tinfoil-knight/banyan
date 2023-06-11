defmodule DnsPacket do
  defstruct header: nil, questions: [], answers: [], authorities: [], additionals: []

  @type t :: %DnsPacket{
          header: DnsHeader,
          questions: [DnsQuestion],
          answers: [DnsRecord],
          authorities: [DnsRecord],
          additionals: [DnsRecord]
        }

  def parse(data) do
    header = DnsHeader.parse(data)
    pos = 12

    {questions, pos} =
      Enum.reduce(1..header.num_questions, {[], pos}, fn _i, acc ->
        {list, pos} = acc
        {question, new_pos} = DnsQuestion.parse(data, pos)
        {list ++ [question], new_pos}
      end)

    {answers, pos} = read_record(data, pos, header.num_answers)
    {authorities, pos} = read_record(data, pos, header.num_authorities)
    {additionals, _pos} = read_record(data, pos, header.num_additionals)

    %DnsPacket{
      header: header,
      questions: questions,
      answers: answers,
      authorities: authorities,
      additionals: additionals
    }
  end

  defp read_record(data, pos, num_record) do
    case num_record do
      0 ->
        {[], pos}

      _ ->
        Enum.reduce(1..num_record, {[], pos}, fn _i, acc ->
          {records, pos} = acc
          {record, new_pos} = DnsRecord.parse(data, pos)
          {records ++ [record], new_pos}
        end)
    end
  end
end
